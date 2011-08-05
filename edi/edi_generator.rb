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

      if inbound?
        unless options[:skip_model]
          m.template "inbound/model.rb", "app/models/#{namespace}/#{class_name}.rb"
        end

        unless options[:skip_controller]
          m.template "inbound/index.html.erb", "app/views/#{namespace}/index.html.erb" 
          m.template "inbound/show.html.erb", "app/views/#{namespace}/show.html.erb"
          m.template "inbound/controller.rb", "app/controllers/#{namespace}/#{plural_name}.rb"
        end
      elsif outbound?
        unless options[:skip_model]
          m.template "outbound/model.rb", "app/models/#{namespace}/#{class_name}.rb"
        end

        unless options[:skip_controller]
          m.template "outbound/index.html.erb", "app/views/#{namespace}/index.html.erb" 
          m.template "outbound/show.html.erb", "app/views/#{namespace}/show.html.erb"
        end
      else
        raise "EDI should be either Inbound or Outbound"
      end

      p namespace
      p name
      p plural_name
      p singular_name
      p class_name
      p inbound?
      p outbound?
      p @attributes
    end
  end

  protected

  def banner 
    <<-EOS
Creates an EDI, with templates for the Controller, Model, View and Observer.

USAGE: ./script/generate edi EdiName [model_field:value] [options]
    EOS
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-model", "Don't generate a model or migration file.") { |v| options[:skip_model] = v }
    opt.on("--skip-controller", "Don't generate controller, helper, or views.") { |v| options[:skip_controller] = v }
    opt.on("--skip-migration", "Don't generate migration file for model.") { |v| options[:skip_migration] = v }
    opt.on("--skip-timestamps", "Don't add timestamps to migration file.") { |v| options[:skip_timestamps] = v }
    opt.on("--invert", "Generate all controller actions except these mentioned.") { |v| options[:invert] = v }
    opt.on("--haml", "Generate HAML views instead of ERB.") { |v| options[:haml] = v }
    opt.on("--testunit", "Use test/unit for test files.") { options[:test_framework] = :testunit }
    opt.on("--shoulda", "Use Shoulda for test files.") { options[:test_framework] = :shoulda }
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

  def api_edi_prefix_given?
    namespace[/^api\/edi/]
  end

  def namespace
    @namespace ||= File.join("api", "edi", @attributes.select {|attr| attr.name == "namespace"}.first.type.to_s) unless api_edi_prefix_given?
    @namespace ||= @attributes.select {|attr| attr.name == "namespace"}.first.type.to_s
  end

  def inbound?
    @name[/inbound/i] && !@name[/outbound/i]
  end

  def outbound?
    @name[/outbound/i] && !@name[/inbound/i]
  end

  def generate_attributes
    @args[1..-1].each do |arg|
      # name => type
      @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":")) if arg.include? ":"
    end
  end

  def generate_skipping
    @skipping ||= (options.keys.select {|key| key =~ /skip_(.*)/}).map {|key| key[/skip_(.*)/, 1]}
  end
end
