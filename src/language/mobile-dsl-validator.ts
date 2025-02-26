import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { MobileDslAstType, Person } from './generated/ast.js';
import type { MobileDslServices } from './mobile-dsl-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: MobileDslServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.MobileDslValidator;
    const checks: ValidationChecks<MobileDslAstType> = {
        Person: validator.checkPersonStartsWithCapital
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class MobileDslValidator {

    checkPersonStartsWithCapital(person: Person, accept: ValidationAcceptor): void {
        if (person.name) {
            const firstChar = person.name.substring(0, 1);
            if (firstChar.toUpperCase() !== firstChar) {
                accept('warning', 'Person name should start with a capital.', { node: person, property: 'name' });
            }
        }
    }

}
