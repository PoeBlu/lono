class Lono::Sets::Instances
  class Options < Lono::Sets::Options
    def delete
      operation_preferences_options
      accounts_options
    end

    def sync
      operation_preferences_options
      accounts_options
      with_cli_scope do
        option :delete, type: :boolean, default: true, desc: "Delete stack instances that are not provided"
        option :blueprint, desc: "override convention and specify the template file to use"
      end
    end

    def accounts_options
      with_cli_scope do
        option :accounts, type: :array, desc: "List of accounts to apply stack set to. IE: 112233445566 223344556677"
        option :regions, type: :array, desc: "List of regions to apply stack set to. IE: us-west-2 us-east-1"
        option :sure, type: :boolean, desc: "Skip are you sure prompt"
      end
    end
  end
end
