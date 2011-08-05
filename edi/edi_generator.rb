# script that is ran by script/generator edi...

class EdiGenerator < Rails::Generator::NamedBase
  # for copying files into application
  attr_accessor :name, :attributes

  def initialize(args, options={})
    super
    usage if args.empty?

    @name = args.first
    @args = args
    @options = options
    @attributes = []
    @skipping = []

    generate_skipping
    generate_attributes
  end

  def manifest
    record do |m|
      # instructing generator what to do by process m
      # filename passed into from the user
      # m.template "model.rb", "app/models/#{file_name}.rb"
      # m.template "view.html.erb", "app/views/#{file_name}.html.erb"
    end
  end

  protected

  def banner 
    <<-EOS
Creates an EDI, with templates for the Controller, Model, View and Observer.

USAGE: ./script/generate edi EdiName [model_field:value] [options]
    EOS
  end

  private

  def plural_name
    name.underscore.pluralize
  end

  def singular_name
    name.underscore
  end

  def class_name
    name.camelize
  end

  def plural_class_name
    plural_name.camelize
  end

  def inbound?
    @name["inbound"] && !@name["outbound"]
  end

  def outbound?
    @name["outbound"] && !@name["inbound"]
  end

  def generate_attributes
    @args[1..-1].each do |arg|
      @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":")) if arg.include? ":"
    end
  end

  def generate_skipping
    @skipping ||= (options.keys.select {|key| key =~ /skip_(.*)/}).map {|key| key[/skip_(.*)/, 1]}
  end
end
