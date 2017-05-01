# Active Record Lite

## Description

Active Record Lite is a simplified implementation of the Object Relational Mapping pattern. It was inspired by the Rails Library Active Record. I built Active Record Lite using metaprogramming techniques in order to substitute the majority of simple SQL queries that are used to access the database on a daily basis.

## Implementation Details

#### SQL Objects

The SQL objects implemented in Active Record Lite include the following methods:
- ::all - returns all instances of SQL object class
- ::find(id) - returns instance of SQL object class with provided id
- ::columns - returns SQL object class's columns
- ::table_name - returns SQL object class's table name
- ::table_name=(table_name) - renames SQL object's table name
- #save - saves SQL object to database
- #attributes - lists SQL object's attributes
- #attribute_values - lists SQL object's attribute values
- #update - Updates SQL object's attributes

Many of these methods rely on DBConnection (found in db_connection.rb) to interact with the database. Here is an example of the insert method:

```
def insert
  col_names = self.class.columns.join(",")
  question_marks = (["?"] * self.class.columns.length).join(",")

  DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name}(#{col_names})
    VALUES
      (#{question_marks})
  SQL

  self.id = DBConnection.last_insert_row_id
end
```

#### "Where" Searches
I have also added a separate "Searchable" module to enable ::where searches across SQL object classes. The code for this module can be found below:

```
module Searchable
  def where(params)
    where_line = params.map { |k, v| "#{k} = ?"}.join(" AND ")
    vals = params.values
    data = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    self.parse_all(data)
  end
end
```


#### Object relationships

In addition to the functionality above, I have also added Active Record associations through the Associable module. This module allows allows different SQL classes to be related to one another through the traditional "belongs_to" and "has_many" relationships. This corresponds to the relationships that are present in SQL tables whenever different tables are connected with the use of a foreign key. Here is an example of the code for #has_many:

```
def has_many(name, options = {})
  self.assoc_options[name] =
    HasManyOptions.new(name, self.name, options)

  define_method(name) do
    options = self.class.assoc_options[name]

    key_val = self.send(options.primary_key)
    options
      .model_class
      .where(options.foreign_key => key_val)
  end
end
```
