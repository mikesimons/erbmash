package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/mikesimons/go-mruby"
)

func runString(mrb *mruby.Mrb, code string, args ...mruby.Value) (*mruby.MrbValue, error) {
	proc, err := mrb.LoadString(fmt.Sprintf("Proc.new { %s }", code))
	if err != nil {
		return nil, err
	}

	return mrb.Yield(proc, args...)
}

func main() {
	log.SetFlags(0)

	eachKey := flag.String("each", "", "Key to iterate over")
	flag.Parse()

	dataFile := flag.Arg(0)
	dataReader, err := os.Open(dataFile)
	if err != nil {
		log.Fatalf("Error opening data: %s", err)
	}

	templateFile := flag.Arg(1)
	templateReader, err := os.Open(templateFile)
	if err != nil {
		log.Fatalf("Error opening template: %s", err)
	}

	templateBytes, err := ioutil.ReadAll(templateReader)
	if err != nil {
		log.Fatalf("Error reading template: %s", err)
	}

	dataBytes, err := ioutil.ReadAll(dataReader)
	if err != nil {
		log.Fatalf("Error reading data: %s", err)
	}

	mrb := mruby.NewMrb()
	defer mrb.Close()

	tmpVal, _ := mrb.LoadString(`{}`)
	opts := tmpVal.Hash()
	opts.Set(mrb.StringValue("each"), mrb.StringValue(*eachKey))

	mrb.LoadString(`
		class Ctx
			def initialize data
				@__data = data
			end

			def data
				@__data
			end
		end

		class Object
			def truthy?
				str_self = self.to_s.downcase

				positive_str = ["true", "y", "yes"].include?(self.to_s)
				return true if positive_str

				negative_str = ["false", "n", "no"].include?(str_self)
				return false if negative_str

				self != 0 && !self.nil? && !str_self.empty?
			end
		end
	`)

	mrbData, err := runString(mrb, `|data| YAML.load(data)`, mrb.StringValue(string(dataBytes)))
	if err != nil {
		log.Fatalf("Error parsing %s: %s", dataFile, err)
	}

	processCode := `|template, data|
		erb = ERB.new(template, nil, "-")
		ctx = Ctx.new data
		erb.result(ctx)
	`

	result, err := runString(
		mrb,
		processCode,
		mrb.StringValue(string(templateBytes)),
		mrbData,
		opts.MrbValue.MrbValue(mrb),
	)

	if err != nil {
		exc := err.(*mruby.Exception)
		log.Fatalf("Error rendering %s at line %d: %s", templateFile, exc.Line, exc.Message)
	}

	fmt.Print(result)
}
