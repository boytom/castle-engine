{
  Copyright 2010-2018 Michalis Kamburelis.

  This file is part of "Castle Game Engine".

  "Castle Game Engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Castle Game Engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{$ifdef read_interface}

  { Possible crosshair shape, for @link(TCastleCrosshair.Shape). }
  TCastleCrosshairShape = (csCross, csCrossRect);

  { Display a simple crosshair in the middle of the parent control. }
  TCastleCrosshair = class(TUIControl)
  strict private
    FShape: TCastleCrosshairShape;
    procedure SetShape(const Value: TCastleCrosshairShape);
    function ImageType: TThemeImage;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Render; override;

    { Size of this control, ignoring GetExists. }
    function Rect: TRectangle; override;
  published
    property Shape: TCastleCrosshairShape read FShape write SetShape default csCross;

    { By default, crosshair is centered. }
    property HasHorizontalAnchor default true;
    property HasVerticalAnchor default true;
    property HorizontalAnchorSelf default hpMiddle;
    property HorizontalAnchorParent default hpMiddle;
    property VerticalAnchorSelf default vpMiddle;
    property VerticalAnchorParent default vpMiddle;
  end;

{$endif read_interface}

{$ifdef read_implementation}

{ TCastleCrosshair ---------------------------------------------------- }

constructor TCastleCrosshair.Create(AOwner: TComponent);
begin
  inherited;
  FShape := csCross;
  Anchor(hpMiddle);
  Anchor(vpMiddle);
end;

procedure TCastleCrosshair.SetShape(const Value: TCastleCrosshairShape);
begin
  FShape := Value;
  VisibleChange;
end;

function TCastleCrosshair.ImageType: TThemeImage;
begin
  if FShape = csCrossRect then
    Result := tiCrosshair2 else
    Result := tiCrosshair1;
end;

function TCastleCrosshair.Rect: TRectangle;
begin
  Result := Theme.Images[ImageType].Rect;

  // applying UIScale on this is easy...
  Result := Result.ScaleAround0(UIScale);
end;

procedure TCastleCrosshair.Render;
begin
  inherited;
  Theme.Draw(ScreenRect, ImageType, UIScale);
end;

{$endif read_implementation}
