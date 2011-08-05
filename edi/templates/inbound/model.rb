# See EdiInbound for database fields
module Api::Edi::Exel::Clorox::RedPrairie
  class EdiInbound846Parser < Nokogiri::XML::SAX::Document
    def initialize edi, mrp_report, inventory, skus_to_include
      @mrp_report = mrp_report
      @edi = edi
      @inventory = inventory
      @skus = skus_to_include
      @text = ''
      @edi.details = []
    end

    def start_element(localname, attributes)
      @text = ''
    end

    def characters text
      @text << text if @text
    end

    def end_element(localname)
      case localname
      when 'item'
        sku_valid = is_valid_part_number
        quantity_valid = is_valid_quantity
        uom_valid = is_valid_uom

        if sku_valid and quantity_valid and uom_valid
          match = @skus.detect {|s| s.code.casecmp(@sku_code) == 0}
          @inventory[match.id] = match.convert_to_eaches(@quantity.to_d, @uom) if match
          @sku_code = nil
          @quantity = nil
          @uom = nil
        else
          @mrp_report.errors.add_to_base "Errors were detected when processing the inbound EDI 846 XML.  Please look at the most recent EDI on the Inbound EDI page for more details."
          @edi.status = EdiInbound::ERROR
        end
      when 'part-number'
        @sku_code = @text.strip
      when 'quantity'
        @quantity = @text.strip
      when 'unit-of-measure'
        @uom = @text.strip
      when 'line-items'
        @edi.save
      end
    end

    def is_valid_part_number
      details = []
      details << "Missing/blank part-number tag." if @sku_code.blank?
      @edi.details += details
      details.empty?
    end

    def is_valid_quantity
      details = []
      details << "Missing/blank quantity tag." if @quantity.blank?
      begin
        Float(@quantity) unless @quantity.blank?
      rescue
        details << "'#{@quantity}' is not a valid number."
      end
      @edi.details += details
      details.empty?
    end

    def is_valid_uom
      details = []
      details << "Missing/blank unit-of-measure tag." if @uom.blank?
      details << "'#{@uom}' is not a valid unit of measure." if not @uom.blank? and not Sku::UOMS.include?(@uom)
      @edi.details += details
      details.empty?
    end
  end

  class EdiInbound846 < EdiInbound

    def object
      #not_implemented!
    end

    def object= obj
      #not_implemented!
    end

    def process_edi hash
      #not_implemented!
    end

    def valid_xml? hash
      #not_implemented!
    end

    # this will parse the EDI and return a hash that represent the inventory in eaches, could be extended to add a UOM param if needed
    # specify a list of subcomponents if you want to filter down the inventory to a specified set
    def inventory mrp_report, only
      results = {}
      selected_skus = self.site.account.skus.find(:all, :conditions => ["id IN (:ids)", {:ids => only}])
      parser = Nokogiri::XML::SAX::Parser.new(EdiInbound846Parser.new(self, mrp_report, results, selected_skus))
      parser.parse(self.request_xml)
      results
    end
  end
end
