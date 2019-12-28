class Lono::Configset
  class Resolver
    extend Memoist

    class_attribute :dependencies # save to regsiter configsets later
    self.dependencies = []

    def resolve(*unresolved)
      unresolved.flatten! # initially only top-level
      puts "Resolving dependencies... #{unresolved.map(&:name)}".color(:yellow)
      unresolved.each do |jade|
        jade.materialize
        puts "unresolved.each jade name #{jade.name} dependencies #{jade.dependencies.map(&:name)}"
        jade.dependencies.each do |j|
          self.class.dependencies << j
          unless j.resolved? or unresolved.include?(j)
            resolve(j)
          end
        end
        jade.resolved!
      end
    end
  end
end
