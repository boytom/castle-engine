{ -*- buffer-read-only: t -*-

  Copyright 2015-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ Automatically generated node properties.

  Do not edit this file manually!
  To add new properties:
  - add them to the text files in nodes_specification/components/ ,
  - and regenerate include files by running
    nodes_specification/x3d-nodes-to-pascal/x3d-nodes-to-pascal.lpr .

  The documentation for properties should go to x3dnodes_documentation.txt . }

{$ifdef read_interface}

  strict private
    function GetColor: TAbstractColorNode;
    procedure SetColor(const Value: TAbstractColorNode);
    function GetFogCoord: TFogCoordinateNode;
    procedure SetFogCoord(const Value: TFogCoordinateNode);
    function GetNormal: TAbstractNormalNode;
    procedure SetNormal(const Value: TAbstractNormalNode);
    function GetTexCoord: TAbstractTextureCoordinateNode;
    procedure SetTexCoord(const Value: TAbstractTextureCoordinateNode);
    function GetCcw: boolean;
    procedure SetCcw(const Value: boolean);
    function GetColorPerVertex: boolean;
    procedure SetColorPerVertex(const Value: boolean);
    function GetCreaseAngle: Single;
    procedure SetCreaseAngle(const Value: Single);
    function GetNormalPerVertex: boolean;
    procedure SetNormalPerVertex(const Value: boolean);
    function GetXDimension: Integer;
    procedure SetXDimension(const Value: Integer);
    function GetXSpacing: Single;
    procedure SetXSpacing(const Value: Single);
    function GetZDimension: Integer;
    procedure SetZDimension(const Value: Integer);
    function GetZSpacing: Single;
    procedure SetZSpacing(const Value: Single);
  public
    procedure SetAttrib(const Value: array of TAbstractVertexAttributeNode);
    property Color: TAbstractColorNode read GetColor write SetColor;
    property FogCoord: TFogCoordinateNode read GetFogCoord write SetFogCoord;
    property Normal: TAbstractNormalNode read GetNormal write SetNormal;
    property TexCoord: TAbstractTextureCoordinateNode read GetTexCoord write SetTexCoord;
    property Ccw: boolean read GetCcw write SetCcw;
    property ColorPerVertex: boolean read GetColorPerVertex write SetColorPerVertex;
    property CreaseAngle: Single read GetCreaseAngle write SetCreaseAngle;
    procedure SetHeight(const Value: array of Single);
    procedure SetHeight(const Value: TSingleList);
    property NormalPerVertex: boolean read GetNormalPerVertex write SetNormalPerVertex;
    property XDimension: Integer read GetXDimension write SetXDimension;
    property XSpacing: Single read GetXSpacing write SetXSpacing;
    property ZDimension: Integer read GetZDimension write SetZDimension;
    property ZSpacing: Single read GetZSpacing write SetZSpacing;

{$endif read_interface}

{$ifdef read_implementation}

{ TElevationGridNode ----------------------------------------------- }

procedure TElevationGridNode.SetAttrib(const Value: array of TAbstractVertexAttributeNode);
var
  L: Integer;
  A: array of TX3DNode;
begin
  L := High(Value) + 1;
  SetLength(A, L);
  if L > 0 then
    Move(Value[0], A[0], L * SizeOf(TAbstractVertexAttributeNode));
  FdAttrib.Send(A);
end;

function TElevationGridNode.GetColor: TAbstractColorNode;
begin
  if FdColor.Value is TAbstractColorNode then
    Result := TAbstractColorNode(FdColor.Value)
  else
    Result := nil;
end;

procedure TElevationGridNode.SetColor(const Value: TAbstractColorNode);
begin
  FdColor.Send(Value);
end;

function TElevationGridNode.GetFogCoord: TFogCoordinateNode;
begin
  if FdFogCoord.Value is TFogCoordinateNode then
    Result := TFogCoordinateNode(FdFogCoord.Value)
  else
    Result := nil;
end;

procedure TElevationGridNode.SetFogCoord(const Value: TFogCoordinateNode);
begin
  FdFogCoord.Send(Value);
end;

function TElevationGridNode.GetNormal: TAbstractNormalNode;
begin
  if FdNormal.Value is TAbstractNormalNode then
    Result := TAbstractNormalNode(FdNormal.Value)
  else
    Result := nil;
end;

procedure TElevationGridNode.SetNormal(const Value: TAbstractNormalNode);
begin
  FdNormal.Send(Value);
end;

function TElevationGridNode.GetTexCoord: TAbstractTextureCoordinateNode;
begin
  if FdTexCoord.Value is TAbstractTextureCoordinateNode then
    Result := TAbstractTextureCoordinateNode(FdTexCoord.Value)
  else
    Result := nil;
end;

procedure TElevationGridNode.SetTexCoord(const Value: TAbstractTextureCoordinateNode);
begin
  FdTexCoord.Send(Value);
end;

function TElevationGridNode.GetCcw: boolean;
begin
  Result := FdCcw.Value;
end;

procedure TElevationGridNode.SetCcw(const Value: boolean);
begin
  FdCcw.Send(Value);
end;

function TElevationGridNode.GetColorPerVertex: boolean;
begin
  Result := FdColorPerVertex.Value;
end;

procedure TElevationGridNode.SetColorPerVertex(const Value: boolean);
begin
  FdColorPerVertex.Send(Value);
end;

function TElevationGridNode.GetCreaseAngle: Single;
begin
  Result := FdCreaseAngle.Value;
end;

procedure TElevationGridNode.SetCreaseAngle(const Value: Single);
begin
  FdCreaseAngle.Send(Value);
end;

procedure TElevationGridNode.SetHeight(const Value: array of Single);
begin
  FdHeight.Send(Value);
end;

procedure TElevationGridNode.SetHeight(const Value: TSingleList);
begin
  FdHeight.Send(Value);
end;

function TElevationGridNode.GetNormalPerVertex: boolean;
begin
  Result := FdNormalPerVertex.Value;
end;

procedure TElevationGridNode.SetNormalPerVertex(const Value: boolean);
begin
  FdNormalPerVertex.Send(Value);
end;

function TElevationGridNode.GetXDimension: Integer;
begin
  Result := FdXDimension.Value;
end;

procedure TElevationGridNode.SetXDimension(const Value: Integer);
begin
  FdXDimension.Send(Value);
end;

function TElevationGridNode.GetXSpacing: Single;
begin
  Result := FdXSpacing.Value;
end;

procedure TElevationGridNode.SetXSpacing(const Value: Single);
begin
  FdXSpacing.Send(Value);
end;

function TElevationGridNode.GetZDimension: Integer;
begin
  Result := FdZDimension.Value;
end;

procedure TElevationGridNode.SetZDimension(const Value: Integer);
begin
  FdZDimension.Send(Value);
end;

function TElevationGridNode.GetZSpacing: Single;
begin
  Result := FdZSpacing.Value;
end;

procedure TElevationGridNode.SetZSpacing(const Value: Single);
begin
  FdZSpacing.Send(Value);
end;

{$endif read_implementation}
