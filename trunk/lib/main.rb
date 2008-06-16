require 'bin'
require 'bin_packer'

require 'input_builder'
require 'output_builder'

$KCODE = 'UTF8'


input_info = InputBuilder.new.build('input_paths.txt')

bin_factory = BinFactory.new(:DVD4_7)
bin_packer = BinPacker.new
result = bin_packer.best_fit(bin_factory, input_info.input_elements)

output_builder = OutputBuilder.new
output_builder.build_report(result)
output_builder.build_delete_script(result)
output_builder.build_disk_burning_projects(result, input_info)