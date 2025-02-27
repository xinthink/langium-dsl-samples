grammar MobileDsl

entry Model:
    (plugins+=Plugin | kernel=MicroKernel | events+=Event)+;

// Core plugin system definitions
Plugin:
    DomainModelPlugin | JourneyPlugin | CapabilityPlugin;

DomainModelPlugin:
    'domain' name=ID '{'
        (states+=State | reducers+=Reducer | commands+=Command)*
    '}';

JourneyPlugin:
    'journey' name=ID '{'
        (views+=View | subscriptions+=Subscription)*
    '}';

CapabilityPlugin:
    'capability' name=ID '{'
        (apis+=API | effects+=Effect)*
    '}';

MicroKernel:
    'kernel' '{'
        eventBus=EventBus
    '}';

Event:
    'event' name=ID ('->' topics+=STRING)*;

EventBus:
    'eventbus' '{'
        routes+=EventRoute*
    '}';

EventRoute:
    from=ID '=>' to=ID;

State:
    'state' name=ID ':' type=Type;

Reducer:
    'reducer' name=ID '('params+=Param')' '=>' action=Action;

Action:
    'action' name=ID '{'
        (effects+=Effect | commands+=Command)*
    '}';

Command:
    'command' name=ID '(' params+=Param ')' '=>' handler=ID;

View:
    'view' name=ID '{'
        (bindings+=DataBinding)*
    '}';

DataBinding:
    'bind' path=Path 'to' component=ID;

Path:
    ID ('.' ID)*;

Subscription:
    'subscribe' event=ID 'from' plugin=ID;

// Capability interface
API:
    'api' name=ID '{'
        endpoints+=Endpoint*
    '}';

Endpoint:
    method=HttpMethod path=STRING ('=>' handler=ID);

HttpMethod: 'GET' | 'POST' | 'PUT' | 'DELETE';

// Effects management
Effect:
    RetryPolicy | CircuitBreaker | Timeout;

RetryPolicy:
    'retry' attempts=INT ('backoff' strategy=BackoffStrategy)?;

CircuitBreaker:
    'circuit-breaker' failureThreshold=INT timeout=INT;

Timeout:
    'timeout' duration=INT;

BackoffStrategy: 'exponential' | 'linear' | 'fixed';

// ==== Type System ====
interface Type {}

interface PrimitiveType extends Type {
    name: 'String' | 'Int' | 'Boolean'
}

interface CompositeType extends Type {
    listType?: Type
    mapKeyType?: Type
    mapValueType?: Type
}

Type returns Type:
    PrimitiveType | CompositeType;

PrimitiveType returns PrimitiveType:
    {PrimitiveType} name=('String' | 'Int' | 'Boolean');

CompositeType returns CompositeType:
    ListType | MapType;

ListType returns CompositeType:
    'List' '<' elementType=Type '>'
    {infer CompositeType}
    ({listType: elementType});

MapType returns CompositeType:
    'Map' '<' keyType=Type ',' valueType=Type '>'
    {
        return {
            mapKeyType: keyType,
            mapValueType: valueType
        };
    };

Param returns Param:
    {Param}
    name=ID ':' type=Type;

Effect returns Effect:
    RetryPolicy | CircuitBreaker | Timeout;

RetryPolicy returns Effect:
    'retry' attempts=INT ('backoff' strategy=BackoffStrategyType)?;

CircuitBreaker returns Effect:
    'circuit-breaker' failureThreshold=INT timeout=INT;

Timeout returns Effect:
    'timeout' duration=INT;

// Command returns Command:
//     {Command}
//     'command' name=ID '(' params+=Param ')' '=>' handler=ID;

// View returns View:
//     {View}
//     'view' name=ID '{'
//         (bindings+=DataBinding)*
//     '}';

// Subscription returns Subscription:
//     {Subscription}
//     'subscribe' event=ID 'from' plugin=ID;

PathExpression:
    first=ID ('::' rest+=ID)*;

HttpMethodType:
    'GET' | 'POST' | 'PUT' | 'DELETE';

BackoffStrategyType:
    'exponential' | 'linear' | 'fixed';

// DataBinding:
//     'bind' path=PathExpression 'to' component=ID ('with' options=BindingOptions)?;

BindingOptions:
    '{'
        (transformers+=Transformer)*
    '}';

Transformer:
    'transform' name=ID '(' params+=TransformParam ')';

TransformParam:
    key=ID '=' value=LiteralValue;

LiteralValue:
    INT | STRING | BooleanValue;

BooleanValue:
    'true' | 'false';

// ListType:
//     'List' '<' elementType=Type '>';

// MapType:
//     'Map' '<' keyType=Type ',' valueType=Type '>';

StateUpdate:
    'update' target=PathExpression 'with' expression=Expression;

Expression:
    ArithmeticExpression | ComparisonExpression | LogicalExpression;

ArithmeticExpression:
    left=PrimaryExpression operator=('+' | '-' | '*' | '/') right=PrimaryExpression;

ComparisonExpression:
    left=PrimaryExpression operator=('==' | '!=' | '>' | '<' | '>=' | '<=') right=PrimaryExpression;

LogicalExpression:
    left=PrimaryExpression operator=('&&' | '||') right=PrimaryExpression;

PrimaryExpression:
    LiteralValue | PathExpression | '(' Expression ')';

hidden terminal WS: /\s+/;
terminal ID: /[_a-zA-Z][\w_]*/;
terminal INT returns number: /[0-9]+/;
terminal STRING: /"(\\.|[^"\\])*"|'(\\.|[^'\\])*'/;

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;
