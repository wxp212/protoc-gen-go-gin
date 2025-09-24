type {{ $.InterfaceName }} interface {
{{range .MethodSet}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{end}}
}
func Register{{ $.InterfaceName }}(r gin.IRouter, srv {{ $.InterfaceName }}) {
	s := {{.Name}}{
		server: srv,
		router:     r,
		resp: default{{$.Name}}Resp{},
	}
	s.RegisterService()
}

type {{$.Name}} struct{
	server {{ $.InterfaceName }}
	router gin.IRouter
	resp  interface {
		Error(ctx *gin.Context, err error)
		ParamsError (ctx *gin.Context, err error)
		Success(ctx *gin.Context, data interface{})
	}
}

// Resp 返回值
type default{{$.Name}}Resp struct {}

func (resp default{{$.Name}}Resp) response(ctx *gin.Context, status int, data interface{}) {
	if status == 200 {
		ctx.JSON(status, data)
		return
	}

	ctx.JSON(status, map[string]interface{}{
		"code": status,
		"msg":  data,
	})
}

// Error 返回错误信息
func (resp default{{$.Name}}Resp) Error(ctx *gin.Context, err error) {
	status := 500

	if err == nil {
		resp.response(ctx, status, "unknown error")
		return
	}

	_ = ctx.Error(err)

	resp.response(ctx, status, err.Error())
}

// ParamsError 参数错误
func (resp default{{$.Name}}Resp) ParamsError (ctx *gin.Context, err error) {
	err = fmt.Errorf("params error: %w", err)

	_ = ctx.Error(err)

	resp.response(ctx, 400, err.Error())
}

// Success 返回成功信息
func (resp default{{$.Name}}Resp) Success(ctx *gin.Context, data interface{}) {
	resp.response(ctx, 200, data)
}


{{range .Methods}}
func (s *{{$.Name}}) {{ .HandlerName }} (ctx *gin.Context) {
	var in {{.Request}}
{{if .HasPathParams }}
	if err := ctx.ShouldBindUri(&in); err != nil {
		s.resp.ParamsError(ctx, err)
		return
	}
{{end}}
{{if eq .Method "GET" "DELETE" }}
	if err := ctx.ShouldBindQuery(&in); err != nil {
		s.resp.ParamsError(ctx, err)
		return
	}
{{else if eq .Method "POST" "PUT" }}
	if err := ctx.ShouldBindJSON(&in); err != nil {
		s.resp.ParamsError(ctx, err)
		return
	}
{{else}}
	if err := ctx.ShouldBind(&in); err != nil {
		s.resp.ParamsError(ctx, err)
		return
	}
{{end}}
	md := metadata.New(nil)
	for k, v := range ctx.Request.Header {
		md.Set(k, v...)
	}
	newCtx := metadata.NewIncomingContext(ctx, md)
	out, err := s.server.({{ $.InterfaceName }}).{{.Name}}(newCtx, &in)
	if err != nil {
		s.resp.Error(ctx, err)
		return
	}

	s.resp.Success(ctx, out)
}
{{end}}

func (s *{{$.Name}}) RegisterService() {
{{range .Methods}}
		s.router.Handle("{{.Method}}", "{{.Path}}", s.{{ .HandlerName }})
{{end}}
}