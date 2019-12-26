class Lono::Configset
  class Dependencies
    extend Memoist

    def resolve(*unresolved)
      puts "Resolving dependencies...".color(:yellow)
      unresolved.flatten!
      unresolved.each do |jade|
        jade.materialize # top-level already materialized but depends_on levels are not yet
        puts "jade #{jade.name} #{jade.class}"
        jade.dependencies.each do |dependency_jade|
          j = dependency_jade
          unless j.resolved? or unresolved.include?(j)
            resolve(j)
          end
        end
        jade.resolved!
      end
    end
  end
end
