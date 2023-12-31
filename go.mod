module github.com/kensei/versioning-master-csv-generator/module/vmcg

go 1.20

replace github.com/kensei/versioning-master-csv-generator => ./

replace github.com/kensei/versioning-master-csv-generator/basestruct => ./basestruct

// bump: tools_protocgen_urfave_cli /github.com\/urfave\/cli\/v2 v([\d.]+)/ https://github.com/urfave/cli.git|*
// bump: tools_protocgen_pkg_errors /github.com\/pkg\/errors v([\d.]+)/ https://github.com/pkg/errors.git|*

require (
	github.com/pkg/errors v0.9.1
	github.com/urfave/cli/v2 v2.25.7
)

require (
	github.com/cpuguy83/go-md2man/v2 v2.0.2 // indirect
	github.com/russross/blackfriday/v2 v2.1.0 // indirect
	github.com/xrash/smetrics v0.0.0-20201216005158-039620a65673 // indirect
)
