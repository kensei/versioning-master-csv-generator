package vmcg

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/pkg/errors"
	"github.com/urfave/cli/v2"
)

type Vmcg struct {
	Argv                 []string
	options              OptionParams
}

// OptionParams is option parameter struct
type OptionParams struct {
	// パラメータオプション
	BaseDir         string
	CsvDir          string
	OutputDir       string
}

// New is constructor
func New() *Vmcg {
	return &Vmcg{
		Argv:   os.Args,
	}
}

// Setup is setup application
func (p *Vmcg) Setup() (err error) {
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
	app.Before = p.setOptions

	// after
	app.After = func(c *cli.Context) error {
		return nil
	}

	// true: go run app.go helpと打ってもhelpが出なくなる
	app.HideHelp = true

	app.Run(os.Args)

	return nil
}

func (v *Vmcg) setOptions(c *cli.Context) error {
	o := &v.options
	o.BaseDir = c.String("basedir")
	baseDir := o.BaseDir
	if baseDir == "" {
		if baseDir = c.String("basedir"); baseDir == "" {
			cwd, err := os.Getwd()
			if err != nil {
				return fmt.Errorf("setOptions Getwd error %s", err)
			}
			baseDir = cwd
		}
		o.BaseDir = baseDir
	}
	o.BaseDir = baseDir
	o.CsvDir = c.String("csvdir")
	if o.CsvDir == "" {
		var csvDir = filepath.Join(baseDir, "csv")
		o.CsvDir = csvDir
	}
	o.OutputDir = c.String("outputdir")
	if o.OutputDir == "" {
		var outputDir = filepath.Join(baseDir, "output")
		o.OutputDir = outputDir
	}
	return nil
}

// Run return Vmcg
func (v *Vmcg) Run() (err error) {
	if err := v.Setup(); err != nil {
		return errors.Wrap(err, "failed to setup Vmcg")
	}
	o := &v.options

	fmt.Println("BaseDir: " + o.BaseDir)
	fmt.Println("CsvDir: " + o.CsvDir)
	fmt.Println("OutputDir: " + o.OutputDir)

	return nil
}
