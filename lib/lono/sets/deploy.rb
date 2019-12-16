class Lono::Sets
  class Deploy < Base
    def run
      params = generate_all
      puts "params #{params.inspect}"
      # if stack_set_exists?(@stack_set_name)
      #   cfn.update_stack_set(params)
      # else
      #   cfn.create_stack_set(params)
      # end
    end

    def generate_all
      Lono::Generate.new(@options).all
    end
  end
end
