  return {
    name = "fundament-institute/website",
    version = "0.0.1",
    description = "The Fundament Research Institute official website",
    tags = { },
    license = "Apache-2.0",
    author = { name = "erikm", email = "" },
    homepage = "",
    public = false,
    dependencies = {
      "creationix/weblit@3.1.2",
      "luvit/luvit@2.5.2",
      "creationix/coro-fs@2.2.3",
      "creationix/coro-split@2.0.0",
      "LeXinshou/smtp-mail@2.5.0"
    },
    files = {
      "**.lua",
      "**.js",
      "**.html",
      "**.css",
      "static/**",
      "!test*"
    }
  }
  
