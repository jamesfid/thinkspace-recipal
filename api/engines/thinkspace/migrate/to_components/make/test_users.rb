module Thinkspace; module Migrate; module ToComponents; module Make
  class TestUsers < Totem::DbMigrate::BaseHelper

    def process
      # destroy_users
      created_users  = Array.new
      existing_users = Array.new
      get_user_attributes.each do |hash|
        attrs = hash.except(:role)
        user  = new_user_class.find_by(attrs)
        if user.present?
          existing_users.push(hash)
        else
          user = new_user_class.create(attrs)
          raise_error "User creation validation errors #{attrs.inspect} #{user.errors.messages}"  if user.errors.present?
          created_users.push(hash)
        end
      end
      add_space_users(created_users)
      if existing_users.present?
        puts "Users already existing (did not create):"
        existing_users.each do |hash|
          puts "  #{hash.inspect}"
        end
      end
      if created_users.present?
        puts "User created:"
        created_users.each do |hash|
          puts "  #{hash.inspect}"
        end
      else
        puts "No new users created."
      end
      puts "\n"
    end

    def destroy_users
      get_user_attributes.each do |hash|
        attrs = hash.except(:role)
        user  = new_user_class.find_by(attrs)
        user.destroy
      end
    end

    def get_user_attributes
      [
        {email: "read_1@sixthedge.com",   first_name: 'read_1',   last_name: 'Doe', role: :read},
        {email: "owner_1@sixthedge.com",  first_name: 'owner_1',  last_name: 'Doe', role: :owner},
        {email: "update_1@sixthedge.com", first_name: 'update_1', last_name: 'Doe', role: :update},
      ]
    end

    def add_space_users(users)
      users.each do |hash|
        role = hash.delete(:role) || :read
        user = new_user_class.find_by(hash)
        raise_error "User defined with #{hash.inspect} not found."  if user.blank?
        new_space_class.all.each do |space|
          create_space_user(space, user, role)
        end
      end
    end

    def create_space_user(space, user, role)
      new_space_user_class.create(
        space_id: space.id,
        user_id:  user.id,
        role:     role.to_s,
      )
    end

    def new_space_class;               get_new_model_class('thinkspace/common/space'); end
    def new_space_user_class;          get_new_model_class('thinkspace/common/space_user'); end
    def new_user_class;                get_new_model_class('thinkspace/common/user'); end

  end
  
end; end; end; end
