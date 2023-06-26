package basestruct

type ContextStruct struct {
	BasePath        string
	InputPath       string
	OutputPath      string
}

type ResultStruct struct {
	Error error
}

type TableStruct struct {
	TableName       string
}
