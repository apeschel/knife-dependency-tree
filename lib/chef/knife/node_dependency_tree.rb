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

    def initialize(name, children=[], color=:red)
      @name = name
      @children = children
      @color = color
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

    def self.roles_to_cookbooks(roles)
      roles.map { |role_name| RoleNode.new(role_name) }
    end

    def self.recipes_to_cookbooks(recipes)
      recipes.map do |recipe|
        recipe.partition("::").first
      end.uniq.map do |cookbook_name|
        CookbookNode.new(cookbook_name)
      end
    end
  end

  class NodeNode < TreeNode
    def initialize(name)
      @@cookbook_versions = get_cookbook_versions(name)
      dependencies = get_dependencies(name)
      color = :green
      super(name, dependencies, color)
    end

    def get_cookbook_versions(name)
      node = ::Chef::Node.load(name)
      environment = ::Chef::Environment.load(node.chef_environment)
      environment.cookbook_versions
    end

    def get_dependencies(name)
      node = ::Chef::Node.load(name)
      cookbooks = TreeNode.recipes_to_cookbooks(node[:recipes])
      roles = TreeNode.roles_to_cookbooks(node[:roles])
      cookbooks + roles
    end
  end

  class RoleNode < TreeNode
    def initialize(name)
      dependencies = get_dependencies(name)
      color = :cyan
      super(name, dependencies, color)
    end

    def get_dependencies(name)
      role = ::Chef::Role.load(name)
      cookbooks = TreeNode.recipes_to_cookbooks(role.run_list.recipes)
      roles = TreeNode.roles_to_cookbooks(role.run_list.roles)
      cookbooks + roles
    end
  end

  class CookbookNode < TreeNode
    def initialize(name)
      @@seen_cookbooks.add(name)
      dependencies = get_dependencies(name)
      color = :yellow
      super(name, dependencies, color)
    end

    def get_dependencies(name)
      cookbook_version = @@cookbook_versions[name]
      cookbooks = []
      if cookbook_version
        cookbook_version = cookbook_version.split.last
        cookbook = rest.get_rest("cookbooks/#{name}/#{cookbook_version}")
        dependencies = cookbook.metadata.dependencies
        cookbooks = dependencies.keys.uniq.reject do |cookbook_name|
          @@seen_cookbooks.include? cookbook_name
        end.map do |cookbook_name|
          CookbookNode.new(cookbook_name)
        end
      end

      return cookbooks
    end
  end

  def run
    node_name = @name_args[0]
    root = NodeNode.new(node_name)
    puts root
  end
end
