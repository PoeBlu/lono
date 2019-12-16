class Lono::Sets
  class Base < Lono::Cfn::Base
    def run
      operation_id = nil
      begin
        operation_id = save
      rescue Exception => e
        puts "#{e.class}: #{e.message}"
      end

      return unless @options[:wait]
      status = Status.new(@stack, operation_id)
      success = status.wait unless @options[:noop]
      exit 1 unless success
      success
    end
  end
end
