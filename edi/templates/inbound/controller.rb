module <%= namespace.modulize %>
  class <%= controller_filename.camelize %>< ApiController
    include ::Edi::InboundRequestHandler
    include ::Edi::InboundRequestDetailedError

    protected

    def edi_class
      <%= class_name %>
    end
  end
end
