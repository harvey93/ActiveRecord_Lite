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
