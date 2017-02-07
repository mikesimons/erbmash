package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"

	"github.com/mikesimons/go-mruby"
	"gopkg.in/urfave/cli.v1"
)

func runString(mrb *mruby.Mrb, code string, args ...mruby.Value) (*mruby.MrbValue, error) {
	proc, err := mrb.LoadString(fmt.Sprintf("Proc.new { %s }", code))
	if err != nil {
		return nil, err
	}

	return mrb.Yield(proc, args...)
}

func readFileOrStdin(file string) ([]byte, error) {
	var reader io.Reader
	var err error

	if file == "-" {
		reader = os.Stdin
	} else {
		reader, err = os.Open(file)
	}

	if err != nil {
		return nil, err
	}

	bytes, err := ioutil.ReadAll(reader)
	if err != nil {
		return nil, err
	}

	return bytes, nil
}

func main() {
	log.SetFlags(0)

	app := cli.NewApp()
	app.Name = "erbmash"
	app.Usage = "Mash json / yaml and erb templates together"
	app.Version = "0.0.6"

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  "data",
			Usage: "JSON / YAML file",
		},
		cli.StringFlag{
			Name:  "erb",
			Usage: "JSON / YAML file",
		},
	}

	app.Action = func(c *cli.Context) error {
		var data []byte

		erb, err := readFileOrStdin(c.String("erb"))
		if err != nil {
			log.Fatalf("Could not open ERB file (%s): %s", c.String("erb"), err)
		}

		if c.String("data") != "" {
			data, err = readFileOrStdin(c.String("data"))
			if err != nil {
				log.Fatalf("Could not open data file (%s): %s", c.String("data"), err)
			}
		}

		mrb := mruby.NewMrb()
		defer mrb.Close()

		tmpVal, _ := mrb.LoadString(`{}`)
		opts := tmpVal.Hash()

		//opts.Set(mrb.StringValue("each"), mrb.StringValue(*eachKey))

		mrb.LoadString(`
			class Erbmash
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

		mrbData, err := runString(mrb, `|data| YAML.load(data)`, mrb.StringValue(string(data)))
		if err != nil {
			log.Fatalf("Error parsing %s: %s", c.String("data"), err)
		}

		processCode := `|template, data|
			erb = ERB.new(template, nil, "-", "$_erbout")
			ctx = Erbmash.new data
			erb.result(ctx)
		`

		result, err := runString(
			mrb,
			processCode,
			mrb.StringValue(string(erb)),
			mrbData,
			opts.MrbValue.MrbValue(mrb),
		)

		if err != nil {
			exc := err.(*mruby.Exception)
			log.Fatalf("Error rendering %s at line %d: %s", c.String("erb"), exc.Line, exc.Message)
		}

		fmt.Print(result)

		return nil
	}

	app.Run(os.Args)
}
