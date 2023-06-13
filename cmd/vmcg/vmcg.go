package main

import (
	"fmt"
	"os"
	"runtime"

	"github.com/kensei/versioning-master-csv-generator/module/vmcg"
)

func main() {
	defer func() {
		if err := recover(); err != nil {
			fmt.Fprintf(os.Stderr, "Error:\n%s", err)
			os.Exit(1)
		}
	}()
	os.Exit(_main())
}

func _main() int {
	cli := vmcg.New()
	if envvar := os.Getenv("GOMAXPROCS"); envvar == "" {
		runtime.GOMAXPROCS(runtime.NumCPU())
	}
	if err := cli.Run(); err != nil {
        fmt.Fprintf(os.Stderr, err.Error())
    }

	return 0
}
