class Dog
    attr_accessor :id, :name, :breed
    
    def initialize(name:, breed:)
        @name = name
        @breed = breed
        @id = nil
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (name, breed);
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed) VALUES (?,?);
        SQL

        DB[:conn].execute(sql, @name, @breed)
        self.id = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", @name)[0][0]
        self
    end

    def self.create(name:, breed:)
        newDog = Dog.new(name: name, breed: breed)
        newDog.save
    end

    def self.new_from_db(row)
        newDog = self.new(name: row[1], breed: row[2])
        newDog.id = row[0]
        newDog
    end

    def self.all
        sql = <<-SQL
            SELECT * FROM dogs
        SQL
        res = []
        
        DB[:conn].execute(sql).each do |row|
            newDog = self.new(name: row[1], breed: row[2])
            newDog.id = row[0]
            res << newDog
        end

        res
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL

        row = DB[:conn].execute(sql, name)
        self.new_from_db(row[0])
    end

    def self.find(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)
        self.new_from_db(row[0])
    end
end
