#define SINGLETON_INTERFACE(CLASSNAME, INSTANCE_GETTER_METHOD)      \
+ (CLASSNAME*)INSTANCE_GETTER_METHOD;                               \


#define SINGLETON_IMPLEMENTATION(CLASSNAME, INSTANCE_GETTER_METHOD) \
                                                                    \
static CLASSNAME* g_shared##CLASSNAME = nil;                        \
                                                                    \
+ (CLASSNAME*)INSTANCE_GETTER_METHOD                                \
{                                                                   \
    if (g_shared##CLASSNAME != nil) {                               \
        return g_shared##CLASSNAME;                                 \
    }                                                               \
                                                                    \
    @synchronized(self) {                                           \
        if (g_shared##CLASSNAME == nil) {                           \
            [[self alloc] init];                                    \
        }                                                           \
    }                                                               \
                                                                    \
    return g_shared##CLASSNAME;                                     \
}                                                                   \
                                                                    \
+ (id)allocWithZone:(NSZone*)zone                                   \
{                                                                   \
    @synchronized(self) {                                           \
        if (g_shared##CLASSNAME == nil) {                           \
            g_shared##CLASSNAME = [super allocWithZone:zone];       \
            return g_shared##CLASSNAME;                             \
        }                                                           \
    }                                                               \
    NSAssert(NO, @ "[" #CLASSNAME                                   \
        " alloc] explicitly called on singleton class.");           \
    return nil;                                                     \
}                                                                   \
                                                                    \
- (id)copyWithZone:(NSZone*)zone                                    \
{                                                                   \
    return self;                                                    \
}                                                                   \
                                                                    \
- (id)retain                                                        \
{                                                                   \
    return self;                                                    \
}                                                                   \
                                                                    \
- (unsigned)retainCount                                             \
{                                                                   \
    return UINT_MAX;                                                \
}                                                                   \
                                                                    \
- (void)release                                                     \
{                                                                   \
}                                                                   \
                                                                    \
- (id)autorelease                                                   \
{                                                                   \
    return self;                                                    \
}
