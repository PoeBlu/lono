class Lono::Configset
  class DependencyResolver < Lono::AbstractBase
    def resolve(metas)
      # metas.each do |meta|
      #   FinalMaterialization.store(meta.name)
      #   dependencies = materialize(meta)
      #   dependencies.each do |m|
      #     next if FinalMaterialization.include?(m.name)
      #     resolve([meta])
      #   end
      # end
    end

    def materialize(meta)

    end
  end
end
