// This file is auto-generated, don't edit it. Thanks.
package com.aliyun.common.models;

import com.aliyun.tea.*;

public class RuntimeObject extends TeaModel {
    @NameInMap("autoretry")
    @Validation(required = true)
    public boolean autoretry;

    @NameInMap("ignoreSSL")
    @Validation(required = true)
    public boolean ignoreSSL;

    @NameInMap("max_attempts")
    @Validation(required = true)
    public Integer maxAttempts;

    @NameInMap("backoff_policy")
    @Validation(required = true)
    public String backoffPolicy;

    @NameInMap("backoff_period")
    @Validation(required = true)
    public Integer backoffPeriod;

    @NameInMap("readTimeout")
    @Validation(required = true)
    public Integer readTimeout;

    @NameInMap("connectTimeout")
    @Validation(required = true)
    public Integer connectTimeout;

    @NameInMap("httpProxy")
    @Validation(required = true)
    public String httpProxy;

    @NameInMap("httpsProxy")
    @Validation(required = true)
    public String httpsProxy;

    @NameInMap("noProxy")
    @Validation(required = true)
    public String noProxy;

    @NameInMap("maxIdleConns")
    @Validation(required = true)
    public Integer maxIdleConns;

    public static RuntimeObject build(java.util.Map<String, ?> map) {
        RuntimeObject self = new RuntimeObject();
        try {
            return TeaModel.build(map, self);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
