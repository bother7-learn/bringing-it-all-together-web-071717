require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize (hash)
    hash.each {|key, value| self.send(("#{key}="), value)}
  end


  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    id_check = DB[:conn].execute("SELECT id FROM dogs WHERE name = ?", self.name)
    self.id = id_check.flatten.last
    self
  end

  def self.create(hash)
    x = Dog.new(hash)
    x.save

  end

  def self.find_by_id(num)
    # binding.pry
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    row = DB[:conn].get_first_row(sql, num)
    x = Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_or_create_by(hash)
    check = DB[:conn].get_first_value("SELECT id FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if check != nil
      Dog.find_by_id(check)
    else
      x = Dog.create(hash)
      x
    end
  end

  def self.new_from_db(row)
    x = Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)
    row = row.last
    x = Dog.new({id: row[0], name: row[1], breed: row[2]})
  end


  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end
