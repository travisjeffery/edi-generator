module <%= namespace.modulize %>
  class <%= class_name %> < EdiInbound
<%= if edi_generate %>
    belongs_to :<%= edi_generate %>, :foreign_key => 'object_id'

    def object
      self.<%= edi_generate %>
    end

    def object=(obj)
      self.<%= edi_generate %> = obj
    end

    def process_edi(params)
      raise "Implement me!"
    end
<% else %>
    def object
      raise "Implement me!"
    end

    def object=(obj)
      raise "Implement me!"
    end
<% end %>

    def valid_xml?(params)
      true
    end
  end 
end
