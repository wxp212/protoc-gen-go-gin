# protoc-gen-go-gin

> 修改自 [kratos v2](https://github.com/go-kratos/kratos/tree/main/cmd/protoc-gen-go-http)
> forked from https://github.com/mohuishou/protoc-gen-go-gin

从 protobuf 文件中生成使用 gin 的 http rpc 服务
## 安装

请确保安装了以下依赖:

- [go 1.16](https://golang.org/dl/)
- [protoc](https://github.com/protocolbuffers/protobuf)
- [protoc-gen-go](https://github.com/protocolbuffers/protobuf-go)

注意由于使用 embed 特性，Go 版本必须大于 1.16

```bash
go install github.com/wxp212/protoc-gen-go-gin@latest
```

## 使用说明

例子见: [example](https://github.com/wxp212/gin-proto)

### proto 文件约定

默认情况下 rpc method 命名为 方法+资源，使用驼峰方式命名，生成代码时会进行映射

方法映射方式如下所示:

- `"GET", "FIND", "QUERY", "LIST", "SEARCH"`  --> GET
- `"POST", "CREATE"`  --> POST
- `"PUT", "UPDATE"`  --> PUT
- `"DELETE"`  --> DELETE

