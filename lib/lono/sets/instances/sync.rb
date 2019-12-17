class Lono::Sets::Instances
  class Sync < Base
    include Validate

    def initialize(options={})
      super
      @regions, @accounts = [], []
    end

    def run
      # TODO: handle parameters :accounts :regions
      # TODO: compute existing instance and run update or create

      validate!

      existing = stack_instances.map do |summary|
        [summary.account, summary.region]
      end

      creates = requested - existing
      updates = requested - creates
      deletes = existing - requested

      puts "creates: #{creates}"
      puts "updates: #{updates}"
      puts "deletes: #{deletes}"

      execute(:create_stack_instances, creates)
      # execute(:update_stack_instances, updates)
      execute(:delete_stack_instances, deletes) if @options[:delete]
    end

  private

    # meth:
    #    create_stack_set
    #    update_stack_set
    #    delete_stack_set
    #
    # instances_data:
    #   [["112233445566", "us-west-1"], ["112233445566", "us-west-1"]]
    #
    def execute(meth, instances_data)
      accounts = accounts_list(instances_data)
      regions = regions_list(instances_data)
      if accounts.empty? or regions.empty?
        # puts "Cannot have one empty. accounts: #{accounts.size} regions: #{regions.size}. No executing #{meth}." # uncomment to debug
        return
      end

      options = {
        stack_set_name: @stack,
        accounts: accounts,
        regions: regions,
      }
      options[:retain_stacks] = false if meth == :delete_stack_instances
      puts "=> Running #{meth} on:"
      puts "accounts: #{accounts.join(',')}"
      puts "regions: #{regions.join(',')}"
      pp options # TODO: delete
      resp = cfn.send(meth, options)
      puts "resp:" # TODO: delete
      pp resp

      o = @options.merge(filter: instances_data)
      o[:start_on_outdated] = true if meth != :delete_stack_instances
      status = Status.new(o)
      status.run unless @options[:noop] # returns success: true or false
    end

    def accounts_list(instances_data)
      instances_data.map { |a| a[0] }.sort.uniq
    end

    def regions_list(instances_data)
      instances_data.map { |a| a[1] }.sort.uniq
    end

    # Simple structure to help with subtracting logic
    # [["112233445566", "us-west-1"], ["112233445566", "us-west-1"]]
    def requested
      requested = []
      accounts.each do |a|
        regions.each do |r|
          item = [a,r]
          requested << item
        end
      end
      requested.sort.uniq
    end
    memoize :requested

    # Override accounts and regions
    def accounts
      @options[:accounts] || lookup(:accounts)
    end

    def regions
      @options[:regions] || lookup(:regions)
    end

    def lookup(config_type)
      config_type = config_type.to_s
      base_path = lookup_config_location(config_type, "base")
      env_path = lookup_config_location(config_type, Lono.env)
      items = load_config(base_path)
      items += load_config(env_path)
      items = items.sort.uniq
      if config_type == :accounts
        @accounts = items
      else
        @regions = items
      end
    end

    def load_config(path)
      return [] unless path

      items = []
      lines = IO.readlines(path)
      lines.map do |l|
        item = l.strip
        items << item unless item.empty?
      end
      items
    end

    def lookup_config_location(config_type, env)
      location = Lono::ConfigLocation.new(config_type, @options, env)
      env == "base" ? location.lookup_base : location.lookup
    end

    def stack_instances
      resp = cfn.list_stack_instances(stack_set_name: @stack)
      resp.summaries
    end
  end
end
