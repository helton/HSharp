{ Just to keep the tightly coupled dependencies of System.Generics.Collections in one place }

unit HSharp.Collections.Interfaces.Internal;

interface

uses
  System.Generics.Collections,
  System.Rtti;

type
  IListInternal<T> = interface
    ['{6EF1CEED-C978-4197-970F-92B85D7F3730}']
    { private }
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
    function GetCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    function GetCount: Integer;
    procedure SetCount(Value: Integer);
    { public }
    procedure Pack(const IsEmpty: TList<T>.TEmptyFunc); overload;
    function RemoveItem(const Value: T; Direction: TList<T>.TDirection): Integer;
    function ExtractItem(const Value: T; Direction: TList<T>.TDirection): T;
    function IndexOfItem(const Value: T; Direction: TList<T>.TDirection): Integer;
    function GetEnumerator: TList<T>.TEnumerator;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
//    property List: arrayofT read FItems;
//    property OnNotify: TCollectionNotifyEvent<T> read FOnNotify write FOnNotify;
  end;

  IDictionaryInternal<TKey,TValue> = interface
    ['{F76723D9-A872-48B7-ACB8-CB34136BF535}']
    { private }
    function GetItem(const Key: TKey): TValue;
    procedure SetItem(const Key: TKey; const Value: TValue);
    function GetCount: Integer;
    function GetKeys: TDictionary<TKey,TValue>.TKeyCollection;
    function GetValues: TDictionary<TKey,TValue>.TValueCollection;
    { public }
    function GetEnumerator: TDictionary<TKey,TValue>.TPairEnumerator;
    property Keys: TDictionary<TKey,TValue>.TKeyCollection read GetKeys;
    property Values: TDictionary<TKey,TValue>.TValueCollection read GetValues;
    property Count: Integer read GetCount;
    property Items[const Key: TKey]: TValue read GetItem write SetItem; default;
//    property OnKeyNotify: TCollectionNotifyEvent<TKey> read FOnKeyNotify write FOnKeyNotify;
//    property OnValueNotify: TCollectionNotifyEvent<TValue> read FOnValueNotify write FOnValueNotify;
  end;

implementation

end.
