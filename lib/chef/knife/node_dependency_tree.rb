class NodeDependencyTree < ::Chef::Knife
  deps do
    require 'chef/json_compat'
    require 'uri'
    require 'chef/cookbook_version'
    require 'set'
  end

  banner "knife node dependency tree NODE"

  class TreeNode < NodeDependencyTree
    @@cookbook_versions = {}
    @@seen_cookbooks = Set.new

    def initialize(name, children=[])
      @name = name
      @children = children
      @color = :red
    end

    def to_s
      pretty_print(0)
    end

    def pretty_print(indent_level)
      output = []
      indent_symbol = "    "
      indent = indent_symbol * indent_level

      output << indent + ::Chef::Knife::ui.color(@name, @color)

      @children.each do |child|
        output << child.pretty_print(indent_level + 1)
      end

      output.join("\n")
    end

    def roles_to_cookbooks(roles)
      roles.map { |role_name| RoleNode.new(role_name) }
    end

    def recipes_to_cookbooks(recipes)
      recipes.map do |recipe|
        recipe.partition("::").first
      end.uniq.map do |cookbook_name|
        CookbookNode.new(cookbook_name)
      end
    end
  end

  class NodeNode < TreeNode
    def initialize(name)
      node = ::Chef::Node.load(name)

      environment = ::Chef::Environment.load(node.chef_environment)
      @@cookbook_versions = environment.cookbook_versions

      cookbooks = recipes_to_cookbooks(node[:recipes])
      roles = roles_to_cookbooks(node[:roles])
      super(name, cookbooks + roles)

      @color = :green
    end
  end

  class RoleNode < TreeNode
    def initialize(name)
      role = ::Chef::Role.load(name)
      cookbooks = recipes_to_cookbooks(role.run_list.recipes)
      roles = roles_to_cookbooks(role.run_list.roles)
      super(name, cookbooks + roles)

      @color = :cyan
    end
  end

  class CookbookNode < TreeNode
    def initialize(name)
      @@seen_cookbooks.add(name)
      # XXX: Clean this up.
      cookbook_version = @@cookbook_versions[name]
      cookbooks = []
      if cookbook_version
        cookbook_version = cookbook_version.split.last
        cookbook = rest.get_rest("cookbooks/#{name}/#{cookbook_version}")
        dependencies = cookbook.manifest["metadata"]["dependencies"]
        cookbooks = dependencies.keys.uniq.reject do |cookbook_name|
          @@seen_cookbooks.include? cookbook_name
        end.map do |cookbook_name|
          CookbookNode.new(cookbook_name)
        end
      end
      super(name, cookbooks)

      @color = :yellow
    end
  end

  def run
    node_name = @name_args[0]
    root = NodeNode.new(node_name)
    puts root
  end
end
