package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/kensei/versioning-master-csv-generator/module/vmcg"
	"github.com/kensei/versioning-master-csv-generator/module/vmcg/basestruct"
	"github.com/urfave/cli/v2"
)

var cCtx basestruct.ContextStruct

func main() {
	// CLI structを生成
	app := cli.NewApp()
	app.Name = "vmcg"
	app.Usage = "vmcg sample"
	app.Version = "0.0.1"

	// グローバルオプション
	app.Flags = []cli.Flag{
		&cli.StringFlag{
			Name:  "basedir, b",
			Value: "",
			// default値をValueからではなくEnvから取る
			EnvVars: []string{"BASE_DIR"},
		},
		&cli.BoolFlag{
			Name:  "debug, d",
			Usage: "デバッグ表示",
		},
		&cli.StringFlag{
			Name:  "csvdir, y",
			Value: "",
		},
		&cli.StringFlag{
			Name:  "outputdir, y",
			Value: "",
		},
	}

	// before
	app.Before = func(c *cli.Context) error {
		return nil
	}

	// after
	app.After = func(c *cli.Context) error {
		return nil
	}

	// true: go run app.go helpと打ってもhelpが出なくなる
	app.HideHelp = true

	app.Action = func(c *cli.Context) error {
		appCtx, err := setOptions(c);
		if err != nil {
			return err
		}

		vmcg := vmcg.Vmcg{
			AppContext: appCtx,
		}

		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()

		result := vmcg.Run(ctx)

		return result.Error
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}

func setOptions(c *cli.Context) (basestruct.ContextStruct, error) {
	cCtx := basestruct.ContextStruct{}
	cCtx.BasePath = c.String("basepath")
	basePath := cCtx.BasePath
	if basePath == "" {
		if basePath = c.String("basepath"); basePath == "" {
			cwd, err := os.Getwd()
			if err != nil {
				fmt.Errorf("setOptions Getwd error %s", err)
				return cCtx, err
			}
			basePath = cwd
		}
	}
	cCtx.BasePath = basePath
	cCtx.InputPath = c.String("csvpath")
	if cCtx.InputPath == "" {
		var inputPath = filepath.Join(basePath, "csv")
		cCtx.InputPath = inputPath
	}
	cCtx.OutputPath = c.String("outputpath")
	if cCtx.OutputPath == "" {
		var outputDir = filepath.Join(basePath, "output")
		cCtx.OutputPath = outputDir
	}
	return cCtx, nil
}
