.libPaths()
library(BiocInstaller)
biocLite("sevenbridges")
require(sevenbridges)
in.lst<-list(
input(id="file", 
  description="the input fastq file",
  inputBinding = CommandLineBinding(
  position = 3L,
  )),
input(id="size", 
inputBinding = CommandLineBinding(
prefix = "--lines=",
position = 1L,
separate = FALSE
)),
input(id="suffix",
inputBinding = CommandLineBinding(
prefix = "--additional-suffix=",
position = 2L,
separate = FALSE
))
)
#
in.lst<-list(
input(id="file", 
  type="File",
  description="the input fastq file",
  inputBinding = CommandLineBinding(
  position = 3L,
  )),
input(id="size",
type="int",
inputBinding = CommandLineBinding(
prefix = "--lines=",
position = 1L,
separate = FALSE
)),
input(id="suffix",
inputBinding = CommandLineBinding(
prefix = "--additional-suffix=",
position = 2L,
separate = FALSE
))
)
in.lst<-list(
input(id="file", 
  type="File",
  description="the input fastq file",
  inputBinding = CommandLineBinding(
  position = 3L
  )),
input(id="size",
type="int",
inputBinding = CommandLineBinding(
prefix = "--lines=",
position = 1L,
separate = FALSE
)),
input(id="suffix",
inputBinding = CommandLineBinding(
prefix = "--additional-suffix=",
position = 2L,
separate = FALSE
))
)
in.lst<-list(
input(id="file", 
  type="File",
  description="the input fastq file",
 # inputBinding = CommandLineBinding(
  position = 3L
 # )
  ),
input(id="size",
type="int",
#inputBinding = CommandLineBinding(
prefix = "--lines=",
position = 1L,
separate = FALSE
#)
),
input(id="suffix",
#inputBinding = CommandLineBinding(
prefix = "--additional-suffix=",
position = 2L,
separate = FALSE
#)
)
)
in.lst<-list(
input(id="file", 
  type="File",
  description="the input fastq file",
 # inputBinding = CommandLineBinding(
  position = 3L
 # )
  ),
input(id="size",
type="int",
#inputBinding = CommandLineBinding(
prefix = "--lines=",
position = 1L,
separate = FALSE
#)
),
input(id="suffix",
type="string",
#inputBinding = CommandLineBinding(
prefix = "--additional-suffix=",
position = 2L,
separate = FALSE
#)
)
)
out.list<-list(
output(id="output", type="array", glob="*$(inputs.suffix)*"),
)
out.list<-list(
output(id="output", type="array", glob="*$(inputs.suffix)*")
)
str(in.lst)
splitter<-Tool(
id="fastq_splitter",
baseCommand="split",
inputs=in.lst,
outputs=out.lst
)
out.lst<-list(
output(id="output", type="array", glob="*$(inputs.suffix)*")
)
splitter<-Tool(
id="fastq_splitter",
baseCommand="split",
inputs=in.lst,
outputs=out.lst
)
str(splitter)
splitter
cat(print(splitter), file="/ngs_share/tools/BS-seq-pipelines/CWL/tools/split_files_alt.yaml"
)
print(splitter)
print(splitter)
out
type(out)
class(out)
splitter
str(splitter)
toYAML(splitter)
splitter$toYAML
catsplitter$toYAML()
cat(splitter$toYAML(), file="/ngs_share/tools/BS-seq-pipelines/CWL/tools/split_files_alt.yaml"
)
steps<-splitter+splitter
library(yaml)
yaml.file<-yaml::yaml.load_file("/ngs_share/tools/BS-seq-pipelines/CWL/tools/trimmomatic.cwl")
yaml.file
trim.cwl<-CWL(yaml.file)
trim.cwl
trim.cwl<-CWL.toYaml(yaml.file)
yaml.file
trimmo<-do.call(Tool, yaml.file)
yaml.file$id
yaml.file$id<-'Trimmomatic'
trimmo<-do.call(Tool, yaml.file)
traceback()
proc.yaml.file<-yaml.file
yaml.file$inputs
proc.yaml.file$inputs<-lapply(yaml.file$inputs, input)
traceback()
options(error=recover)
proc.yaml.file$inputs<-lapply(yaml.file$inputs, input)
ls()
o
java_opts
ls()
Q
length(yaml.file$inputs)
names(yaml.file$inputs)
str(yaml.file$inputs)
proc.yaml.file$inputs<-lapply(yaml.file$inputs, function(inp) do.call("input", inp))
options(error=NULL)
proc.yaml.file$inputs<-lapply(yaml.file$inputs, function(inp) do.call("input", inp))
proc.yaml.file$inputs<-lapply(yaml.file$inputs, function(inp) {for(field in names(inp$inputBinding)) inp[[field]]<-inp$inputBinding[[field]]; inp$inputBinding<-NULL ;do.call("input", inp)})
str(yaml.file$inputs)
proc.yaml.file$inputs<-lapply(yaml.file$inputs, function(inp) {for(field in c("position","prefix","separate")) inp[[field]]<-inp$inputBinding[[field]]; inp$inputBinding<-NULL ;do.call("input", inp)})
warnings()
proc.yaml.file$inputs
str(yaml.file$outputs)
proc.yaml.file$outputs<-lapply(yaml.file$outputs, function(outp) {for(field in c("glob")) outp[[field]]<-inp$outputBinding[[field]]; outp$outputBinding<-NULL ;do.call("output", outp)})
proc.yaml.file$outputs<-lapply(yaml.file$outputs, function(outp) {for(field in c("glob")) outp[[field]]<-outp$outputBinding[[field]]; outp$outputBinding<-NULL ;do.call("output", outp)})
warnings()
tool.obj<-do.call("Tool", proc.yaml.file)
proc.yaml.file$cwlVersion<-NULL
tool.obj<-do.call("Tool", proc.yaml.file)
proc.yaml.file$requirements
sevenbridges::requirements
proc.yaml.file$requirements<-do.call("requirements", proc.yaml.file$requirements)
proc.yaml.file$requirements
proc.yaml.file$requirements<-NULL
tool.obj<-do.call("Tool", proc.yaml.file)
tool.obj
savehistory("/ngs_share/tools/BS-seq-pipelines/CWL/tool_from_yaml.R")
