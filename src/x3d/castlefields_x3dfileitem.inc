{
  Copyright 2002-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{$ifdef read_interface}

  { Base class for any item within VRML/X3D file: a node, a field, a route,
    a prototype etc. We need a common base class for all such things
    to store PositionInParent.

    About ancestry: TX3DFieldOrEvent make use of Assign mechanism
    and so need to descend from TPersistent. TX3DNode make use
    of interfaces and so must descend from something like
    TNonRefCountedInterfacedXxx. These are the only reasons, for now,
    why this descends from TNonRefCountedInterfacedPersistent. }
  TX3DFileItem = class(TNonRefCountedInterfacedPersistent)
  private
    FPositionInParent: Integer;

    { Secondary order for saving items to VRML/X3D file.
      When PositionInParent are equal, this decides which item is first.
      It may be useful, since SortPositionInParent is not a stable sort
      (because QuickSort is not stable), so using this to preserve order
      may be helpful.

      TX3DFileItemList.Add sets this, which allows to preserve
      order when saving. }
    PositionOnList: Integer;
  public
    constructor Create;

    { Position of this item within parent VRML/X3D node, used for saving
      the VRML/X3D graph to file. Default value -1 means "undefined".

      For normal usage and processing of VRML graph, this is totally not needed.
      This position doesn't dictate actual meaning of VRML graph.
      If you're looking to change order of nodes, you probably want
      to rather look at something like ReplaceItems within TMFNode or such.

      This field is purely a hint when encoding VRML file how to order
      VRML items (nodes, fields, routes, protos) within parent node
      or the VRML file. Reason: VRML allows non-unique node names.
      Each DEF XXX overrides all previous ("previous" in lexical sense,
      i.e. normal order of tokens in the file) DEF XXX with the same XXX,
      thus hiding previous node name "XXX".
      This means that when saving VRML file we have to be very careful
      about the order of items, such that e.g. all routes are specified
      when appropriate node names are bound.

      This is a relative position, relative to other PositionInParent
      value of other TX3DFileItem items. So it's not necessary
      to keep all PositionInParent different or successive within some
      parent. When saving, we will sort everything according to
      PositionInParent.

      See e.g. ../../../demo_models/x3d/tricky_def_use.x3dv
      for tests of some tricky layout. When reading such file we have
      to record PositionInParent to be able to save such file correctly. }
    property PositionInParent: Integer
      read FPositionInParent write FPositionInParent default -1;

    { Save to stream. }
    procedure SaveToStream(Writer: TX3DWriter); virtual; abstract;

    { How is this saved to X3D XML encoding. This determines when
      SaveToStream is called. It also cooperates with some SaveToStream
      implementations, guiding how the item is actually saved.
      By default it is sxChildElement. }
    function SaveToXml: TSaveToXmlMethod; virtual;
  end;

  TX3DFileItemList = class({$ifdef CASTLE_OBJFPC}specialize{$endif} TObjectList<TX3DFileItem>)
  public
    procedure SortPositionInParent;
    { Sort all items by PositionInParent and then save them all to stream. }
    procedure SaveToStream(Writer: TX3DWriter);
    procedure Add(Item: TX3DFileItem);
  end;

{$endif read_interface}

{$ifdef read_implementation}

{ TX3DFileItem -------------------------------------------------------------- }

constructor TX3DFileItem.Create;
begin
  inherited;
  FPositionInParent := -1;
end;

function TX3DFileItem.SaveToXml: TSaveToXmlMethod;
begin
  Result := sxChildElement;
end;

{ TX3DFileItemList --------------------------------------------------------- }

function IsSmallerPositionInParent(constref A, B: TX3DFileItem): Integer;
begin
  Result := A.PositionInParent - B.PositionInParent;
  if Result = 0 then
    Result := A.PositionOnList - B.PositionOnList;
end;

procedure TX3DFileItemList.SortPositionInParent;
type
  TX3DFileItemComparer = {$ifdef CASTLE_OBJFPC}specialize{$endif} TComparer<TX3DFileItem>;
begin
  Sort(TX3DFileItemComparer.Construct(@IsSmallerPositionInParent));
end;

procedure TX3DFileItemList.SaveToStream(Writer: TX3DWriter);
var
  I: Integer;
begin
  SortPositionInParent;
  for I := 0 to Count - 1 do
    Items[I].SaveToStream(Writer);
end;

procedure TX3DFileItemList.Add(Item: TX3DFileItem);
begin
  Item.PositionOnList := Count;
  inherited Add(Item);
end;

{$endif read_implementation}
