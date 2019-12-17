class Lono::Sets::Instances
  class Sync < Base
    include Validate
    include Lono::Utils::Sure

    def initialize(options={})
      super
      @regions, @accounts = [], []
    end

    def run
      validate!

      existing = stack_instances.map do |summary|
        [summary.account, summary.region]
      end

      creates = requested - existing
      deletes = existing - requested

      if creates.empty? and deletes.empty?
        puts <<~EOL
          Nothing to be synced in terms of creating and deleting stack instances.  If you want to update the entire
          stack set instead, use the `lono sets deploy` command.
        EOL
        return
      end
      sure?("Are you sure you want to sync stack instances?", desc(creates: creates, deletes: deletes))

      execute(:create_stack_instances, creates)
      execute(:delete_stack_instances, deletes) if @options[:delete]
    end

  private

    # data:
    #    {creates: creates, deletes: deletes}
    # where creates and deletes are instances_data structures:
    #    [["112233445566", "us-west-1"], ["112233445566", "us-west-1"]]
    def desc(data={})
      desc = "lono will run:\n"
      verbs = [:creates, :deletes]
      verbs.each do |verb|
        unless data[verb].empty?
          info = {
            accounts: accounts_list(data[verb]).join(','),
            regions: regions_list(data[verb]).join(','),
          }
          message = <<~EOL
            #{verb.to_s.singularize}_stack_instances for:
              accounts: #{info[:accounts]}
              regions: #{info[:regions]}
          EOL
          desc << message
        end
      end
      desc
    end

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
      puts <<~EOL
        => Running #{meth} on:"
          accounts: #{accounts.join(',')}"
          regions: #{regions.join(',')}"
      EOL
      cfn.send(meth, options) # resp has resp[:operation_id]

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
