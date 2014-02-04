unit HSharp.Mapping.Attributes;

interface

type
  Table = class(TCustomAttribute)
  private
    FTableName: string;
  public
    constructor Create(aTableName: string);
  end;

  Column = class(TCustomAttribute)
  private
    FColumnName: string;
  public
    constructor Create(aColumnName: string);
  end;

  Entity = class(TCustomAttribute);

  Automapping = class(TCustomAttribute);

implementation

{ Table }

constructor Table.Create(aTableName: string);
begin
  inherited Create;
  FTableName := aTableName;
end;

{ Column }

constructor Column.Create(aColumnName: string);
begin
  inherited Create;
  FColumnName := aColumnName;
end;

end.
