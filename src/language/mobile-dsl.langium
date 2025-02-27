grammar MobileDsl

entry Model:
    (plugins+=Plugin | kernel=MicroKernel | events+=Event)+;

// 插件系统核心定义
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

// 事件系统
Event:
    'event' name=ID ('->' topics+=STRING)*;

EventBus:
    'eventbus' '{'
        routes+=EventRoute*
    '}';

EventRoute:
    from=ID '=>' to=ID;

// 状态管理
State:
    'state' name=ID ':' type=Type;

Reducer:
    'reducer' name=ID '('params+=Param')' '=>' action=Action;

Action:
    'action' name=ID '{'
        (effects+=Effect | commands+=Command)*
    '}';

// 命令模式
Command:
    'command' name=ID '(' params+=Param ')' '=>' handler=ID;

// 视图系统
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

// 能力接口
API:
    'api' name=ID '{'
        endpoints+=Endpoint*
    '}';

Endpoint:
    method=HttpMethod path=STRING ('=>' handler=ID);

HttpMethod: 'GET' | 'POST' | 'PUT' | 'DELETE';

// 副作用管理
Effect:
    RetryPolicy | CircuitBreaker | Timeout;

RetryPolicy:
    'retry' attempts=INT ('backoff' strategy=BackoffStrategy)?;

CircuitBreaker:
    'circuit-breaker' failureThreshold=INT timeout=INT;

Timeout:
    'timeout' duration=INT;

BackoffStrategy: 'exponential' | 'linear' | 'fixed';

// ==== 类型系统 ====
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

// 路径表达式
PathExpression:
    first=ID ('::' rest+=ID)*;

// HTTP方法类型
HttpMethodType:
    'GET' | 'POST' | 'PUT' | 'DELETE';

// 退避策略类型
BackoffStrategyType:
    'exponential' | 'linear' | 'fixed';

// // 数据绑定
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

// // 复合类型定义
// ListType:
//     'List' '<' elementType=Type '>';

// MapType:
//     'Map' '<' keyType=Type ',' valueType=Type '>';

// 状态更新操作
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
