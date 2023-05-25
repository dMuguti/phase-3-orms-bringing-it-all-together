require 'sqlite3'
class Dog
  attr_accessor :name, :breed, :id
  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  def save
    if self.id
      update
    else
      insert
    end
    self
  end
  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end
  def self.new_from_db(row)
    id, name, breed = row
    Dog.new(id: id, name: name, breed: breed)
  end
  def self.all
    sql = <<-SQL
      SELECT * FROM dogs
    SQL
    results = DB[:conn].execute(sql)
    results.map { |row| self.new_from_db(row) }
  end
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name).first
    self.new_from_db(result) if result
  end
  def self.find(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    result = DB[:conn].execute(sql, id).first
    self.new_from_db(result) if result
  end
end