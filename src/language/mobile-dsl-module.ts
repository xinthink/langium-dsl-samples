import { type Module, inject } from 'langium';
import { createDefaultModule, createDefaultSharedModule, type DefaultSharedModuleContext, type LangiumServices, type LangiumSharedServices, type PartialLangiumServices } from 'langium/lsp';
import { MobileDslGeneratedModule, MobileDslGeneratedSharedModule } from './generated/module.js';
import { MobileDslValidator, registerValidationChecks } from './mobile-dsl-validator.js';

/**
 * Declaration of custom services - add your own service classes here.
 */
export type MobileDslAddedServices = {
    validation: {
        MobileDslValidator: MobileDslValidator
    }
}

/**
 * Union of Langium default services and your custom services - use this as constructor parameter
 * of custom service classes.
 */
export type MobileDslServices = LangiumServices & MobileDslAddedServices

/**
 * Dependency injection module that overrides Langium default services and contributes the
 * declared custom services. The Langium defaults can be partially specified to override only
 * selected services, while the custom services must be fully specified.
 */
export const MobileDslModule: Module<MobileDslServices, PartialLangiumServices & MobileDslAddedServices> = {
    validation: {
        MobileDslValidator: () => new MobileDslValidator()
    }
};

/**
 * Create the full set of services required by Langium.
 *
 * First inject the shared services by merging two modules:
 *  - Langium default shared services
 *  - Services generated by langium-cli
 *
 * Then inject the language-specific services by merging three modules:
 *  - Langium default language-specific services
 *  - Services generated by langium-cli
 *  - Services specified in this file
 *
 * @param context Optional module context with the LSP connection
 * @returns An object wrapping the shared services and the language-specific services
 */
export function createMobileDslServices(context: DefaultSharedModuleContext): {
    shared: LangiumSharedServices,
    MobileDsl: MobileDslServices
} {
    const shared = inject(
        createDefaultSharedModule(context),
        MobileDslGeneratedSharedModule
    );
    const MobileDsl = inject(
        createDefaultModule({ shared }),
        MobileDslGeneratedModule,
        MobileDslModule
    );
    shared.ServiceRegistry.register(MobileDsl);
    registerValidationChecks(MobileDsl);
    if (!context.connection) {
        // We don't run inside a language server
        // Therefore, initialize the configuration provider instantly
        shared.workspace.ConfigurationProvider.initialized({});
    }
    return { shared, MobileDsl };
}
