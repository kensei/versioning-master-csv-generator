package vmcg

import (
	"fmt"
	"context"

	"github.com/kensei/versioning-master-csv-generator/module/vmcg/basestruct"
)

type Vmcg struct {
	AppContext basestruct.ContextStruct
}

func (app *Vmcg) Run(c context.Context) (basestruct.ResultStruct) {
	appCtx := &app.AppContext
	fmt.Println("BasePath: " + appCtx.BasePath)
	fmt.Println("InputPath: " + appCtx.InputPath)
	fmt.Println("OutputPath: " + appCtx.OutputPath)

	result := basestruct.ResultStruct{}

	return result
}
