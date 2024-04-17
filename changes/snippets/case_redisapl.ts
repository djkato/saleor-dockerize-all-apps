  case "redis": {
    if (!process.env.REDIS_URL) throw new Error("Missing redis url");
    if (!process.env.APP_API_BASE_URL)
      throw new Error("Redis relies on APP_API_BASE_URL to store keys, please set env variable");
    apl = new RedisAPL({ redisUrl: process.env.REDIS_URL, appApiBaseUrl: process.env.APP_API_BASE_URL });
    console.log(apl)
    break;
  }
