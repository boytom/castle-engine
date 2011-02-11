{
  Copyright 2003-2010 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; see the file COPYING.txt,
  included in this distribution, for details about the copyright.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  ----------------------------------------------------------------------------
}

{ VRML lights OpenGL rendering. }
unit VRMLGLLightSet;

interface

uses VectorMath, GL, GLU, KambiGLUtils, VRMLNodes, VRMLLightSet;

type
  { Modify light's properties of the light right before it's rendered.
    Currently, you can modify only the "on" state.

    By default, LightOn is the value of Light.LightNode.FdOn field.
    You can change it if you want. }
  TVRMLLightRenderEvent = procedure (const Light: TActiveLight;
    var LightOn: boolean) of object;

{ Set up OpenGL light properties based on VRML Light properties.
  Basically this just calls something like

@longCode(#
  glLight*(GL_LIGHT0 + glLightNum, ..., ...)
#)

  to set OpenGL light.

  Requires that current OpenGL matrix is modelview.
  Always preserves the matrix value (by using up to one modelview
  matrix stack slot). You can safely wrap this procedure inside an OpenGL
  display list.

  If UseLightOnProperty than we will examine Light.LightNode.FdOn.Value
  and we will call glEnable or glDisable on this light.
  If not UseLightOnProperty, then we will always proceed like the light
  was already on, and we will not call any glEnable or glDisable.

  We make no assumptions about the current state of this OpenGL light.
  We simply always set all the parameters to fully define the required
  light behavior. Some light parameters may not be set, but only because
  they are not used --- for example, if a light is not a spot light,
  then we set GL_SPOT_CUTOFF to 180 (indicates that light has no spot),
  but don't necessarily set GL_SPOT_DIRECTION or GL_SPOT_EXPONENT
  (as OpenGL will not use them anyway). Similarly, if UseLightOnProperty = true
  and the light's node has "on" = FALSE, then we can simply call glDisable
  for this light, and leave it's parameters untouched (because there's
  no point in setting them). }
procedure glLightFromVRMLLight(glLightNum: Integer; const Light: TActiveLight;
  UseLightOnProperty: boolean;
  LightRenderEvent: TVRMLLightRenderEvent);

{ Set up OpenGL lights properties to correspond to given VRML lights.
  We touch only OpenGL lights between glLightNum1 .. glLightNum2.
  If this range is too small for LightsCount, then the remaining VRML lights
  will be ignored. If this range is too large for LightsCount, then the remaining
  OpenGL lights will be simply disabled.

  Each single light is configured by glLightFromVRMLLight
  (with UseLightOnProperty = true). So, just like glLightFromVRMLLight:
  we will enable / disable every light and set it's properties to guarantee
  necessary behavior. We require that current OpenGL matrix is modelview,
  we may require one modelview stack slot, we will always preserve
  the modelview matrix value.

  @groupBegin }
procedure glLightsFromVRML(Lights: PArray_ActiveLight; LightsCount: Integer;
  glLightNum1, glLightNum2: Integer;
  LightRenderEvent: TVRMLLightRenderEvent); overload;

procedure glLightsFromVRML(Lights: TDynActiveLightArray;
  glLightNum1, glLightNum2: Integer;
  LightRenderEvent: TVRMLLightRenderEvent); overload;
{ @groupEnd }

type
  { Render many light sets (TDynActiveLightArray) and avoid
    to configure the same light many times.

    The idea is that calling @link(Render) is just like doing glLightsFromVRML,
    that is it sets up given OpenGL lights. But this class remembers what
    VRML light was set on what OpenGL light, and assumes that VRML lights
    don't change during TVRMLGLLightsCachingRenderer execution. So OpenGL
    light will not be configured again, if it's already configured
    correctly.

    Note that LightRenderEvent event for this must be deterministic,
    based purely on light properties. For example, it's Ok to
    make LightRenderEvent that turns off lights that have kambiShadows = TRUE.
    It is @italic(not Ok) to make LightRenderEvent that sets LightOn to
    random boolean value. IOW, caching here assumes that for the same Light
    values, LightRenderEvent will set LightOn the same. }
  TVRMLGLLightsCachingRenderer = class
  private
    FGLLightNum1, FGLLightNum2: Integer;
    FLightRenderEvent: TVRMLLightRenderEvent;
    LightsKnown: boolean;
    LightsDone: array of PActiveLight;
  public
    { Statistics of how many OpenGL light setups were done
      (Statistics[true]) vs how many were avoided (Statistics[false]).
      This allows you to decide is using TVRMLGLLightsCachingRenderer
      class sensible (as opposed to directly rendering with glLightsFromVRML
      calls). }
    Statistics: array [boolean] of Cardinal;

    constructor Create(const AGLLightNum1, AGLLightNum2: Integer;
      const ALightRenderEvent: TVRMLLightRenderEvent);

    { Render lights. Lights (TDynActiveLightArray) may be @nil,
      it's equal to passing an empty array of lights.

      Returns LightsEnabled, a number of enabled lights, including GLLightNum1
      (in other words, it assumes that first GLLightNum1 lights are already
      reserved and enabled by caller). }
    procedure Render(Lights: TDynActiveLightArray; out LightsEnabled: Cardinal);
    procedure Render(Lights: PArray_ActiveLight; LightsCount: Integer;
      out LightsEnabled: Cardinal);

    property GLLightNum1: Integer read FGLLightNum1;
    property GLLightNum2: Integer read FGLLightNum2;
    property LightRenderEvent: TVRMLLightRenderEvent read FLightRenderEvent;
  end;

  { Load VRML/X3D lights from a file, and render them to OpenGL.
    This allows you to load lights from a VRML/X3D file,
    and use these lights with any 3D objects (for example,
    maybe you want to share the same lights across many TVRMLGLScene
    or other 3D objects you render with OpenGL). }
  TVRMLGLLightSet = class(TVRMLLightSet)
  private
    FGLLightNum1, FGLLightNum2: Integer;

    { This is like GLLightNum2, but it's not -1. }
    function RealGLLightNum2: Integer;
  public
    { Constructor. Forces you to provide values for properties that
      have no sensible (and safe) default, like GLLightNum1, GLLightNum2. }
    constructor Create(ARootNode: TVRMLNode; AOwnsRootNode: boolean;
      AGLLightNum1, AGLLightNum2: Integer);

    { Number of the first OpenGL light that we can set.
      Just like for glLightsFromVRML. }
    property glLightNum1: Integer read FGLLightNum1 write FGLLightNum1;

    { Number of the last OpenGL light that we can set.
      Just like for glLightsFromVRML.

      May be set to -1, to indicate that all the lights (from glLightNum1)
      are available to use. In other words, -1 is equivalent to
      glGet(GL_MAX_LIGHT)-1. }
    property glLightNum2: Integer read FGLLightNum2 write FGLLightNum2;

    { Set up OpenGL lights properties to correspond to given VRML lights.
      This is a wrapper around glLightsFromVRML. }
    procedure RenderLights;

    { Disable all the OpenGL lights (in glLightNum1 .. glLightNum2 range). }
    procedure TurnLightsOff;

    { Disable all the lights not supposed to shine in the shadow,
      for shadow volumes.

      Simply disables lights with @code(kambiShadows) field set to @true.
      See [http://vrmlengine.sourceforge.net/kambi_vrml_extensions.php#ext_shadows]
      for more info.

      Lights with kambiShadows = FALSE are ignored:
      they are left untouched by this method (they are
      neither disabled, nor enabled --- usually you should enable them
      as needed by RenderLights). }
    procedure TurnLightsOffForShadows;
  end;

implementation

uses SysUtils, KambiUtils, Math;

procedure glLightFromVRMLLight(glLightNum: Integer; const Light: TActiveLight;
  UseLightOnProperty: boolean;
  LightRenderEvent: TVRMLLightRenderEvent);

  procedure glLightFromVRMLLightAssumeOn;

    { SetupXxx light : setup glLight properties GL_POSITION, GL_SPOT_* }
    procedure SetupDirectionalLight(LightNode: TVRMLDirectionalLightNode);
    begin
     glLightv(glLightNum, GL_POSITION, Vector4Single(VectorNegate(LightNode.FdDirection.Value), 0));
     glLighti(glLightNum, GL_SPOT_CUTOFF, 180);
    end;

    procedure SetupPointLight(LightNode: TVRMLPointLightNode);
    begin
     glLightv(glLightNum, GL_POSITION, Vector4Single(LightNode.FdLocation.Value, 1));
     glLighti(glLightNum, GL_SPOT_CUTOFF, 180);
    end;

    procedure SetupSpotLight_1(LightNode: TNodeSpotLight_1);
    begin
     glLightv(glLightNum, GL_POSITION, Vector4Single(LightNode.FdLocation.Value, 1));

     glLightv(glLightNum, GL_SPOT_DIRECTION, LightNode.FdDirection.Value);
     glLightf(glLightNum, GL_SPOT_EXPONENT, LightNode.SpotExp);
     glLightf(glLightNum, GL_SPOT_CUTOFF,
       { Clamp to 90 for safety, see VRML 2.0 version for comments }
       Min(90, RadToDeg(LightNode.FdCutOffAngle.Value)));
    end;

    procedure SetupSpotLight_2(LightNode: TNodeSpotLight_2);
    begin
     glLightv(glLightNum, GL_POSITION, Vector4Single(LightNode.FdLocation.Value, 1));

     glLightv(glLightNum, GL_SPOT_DIRECTION, LightNode.FdDirection.Value);

     { There is no way to translate beamWidth to OpenGL's GL_SPOT_EXPONENT.
       In OpenGL spotlight, there is *no* way to specify that light
       is uniform (maximum) within beamWidth, and that light amount
       falls linearly from beamWidth to cutOffAngle.
       In OpenGL, light intensity drops off by
       cosinus(of the angle)^GL_SPOT_EXPONENT.

       No sensible way to even approximate VRML behavior ?

       We can accurately express one specific case (that is
       actually the default, in you will not give beamWidth
       value in VRML 2.0): if beamWidth >= cutOffAngle, the light
       is maximum within full cutOffAngle. This is easy to
       do, just set spot_exponent to 0, then
       cosinus(of the angle)^GL_SPOT_EXPONENT is always 1.

       For other values of beamWidth, I just set spot_exponent
       to some arbitrary value and hope that result will look sensible...

       TODO: some VRML 2.0 extension to allow specifying
       exponent directly would be useful to give user actual
       control over this. Probably just add dropOffRate field
       (like in VRML 1.0) with def value like -1 and say that
       "dropOffRate < 0 means that we should try to approx
       beamWidth, otherwise dropOffRate is used".

       Looking at how other VRML implementations handle this:
       - Seems that most of them ignore the issue, leaving spot exponent
         always 0 and ignoring beamWidth entirely.
       - One implementation
         [http://arteclab.artec.uni-bremen.de/courses/mixed-reality/material/ARToolkit/ARToolKit2.52vrml/lib/libvrml/libvrml97gl/src/vrml97gl/old_ViewerOpenGL.cpp]
         does exactly like me --- checks beamWidth < cutOffAngle
         and sets spot_exponent to 0 or 1.
       - FreeWRL
         [http://search.cpan.org/src/LUKKA/FreeWRL-0.14/VRMLRend.pm]
         uses more intelligent approach setting
         GL_SPOT_EXPONENT to 0.5/ (beamWidth + 0.1).
         Which gives
           beamWidth = 0 => GL_SPOT_EXPONENT = 5
           beamWidth = Pi/4 => GL_SPOT_EXPONENT =~ 0.5 / 0.9 =~ 1/2
           beamWidth = Pi/2 => GL_SPOT_EXPONENT =~ 0.5 / 1.67 =~ 1/3
         Honestly I don't see how it's much better than our atbitrary way... }
     if LightNode.FdBeamWidth.Value >= LightNode.FdCutOffAngle.Value then
       glLightf(glLightNum, GL_SPOT_EXPONENT, 0) else
       glLightf(glLightNum, GL_SPOT_EXPONENT, 1
         { 0.5 / (LightNode.FdBeamWidth.Value + 0.1) });

     glLightf(glLightNum, GL_SPOT_CUTOFF,
       { Clamp to 90, to protect against user inputting invalid value in VRML,
         or just thing like 1.5708, which may be recalculated by
         RadToDeg to 90.0002104591, so > 90, and OpenGL raises "invalid value"
         error then... }
       Min(90, RadToDeg(LightNode.FdCutOffAngle.Value)));
    end;

  var SetNoAttenuation: boolean;
      Attenuat: TVector3Single;
      Color3, AmbientColor3: TVector3f;
      Color4, AmbientColor4: TVector4f;
  begin
   glPushMatrix;
   try
    glMultMatrix(Light.Transform);

    if Light.LightNode is TVRMLDirectionalLightNode then
      SetupDirectionalLight(TVRMLDirectionalLightNode(Light.LightNode)) else
    if Light.LightNode is TVRMLPointLightNode then
      SetupPointLight(TVRMLPointLightNode(Light.LightNode)) else
    if Light.LightNode is TNodeSpotLight_1 then
      SetupSpotLight_1(TNodeSpotLight_1(Light.LightNode)) else
    if Light.LightNode is TNodeSpotLight_2 then
      SetupSpotLight_2(TNodeSpotLight_2(Light.LightNode)) else
      raise EInternalError.Create('Unknown light node class');

    { setup attenuation for OpenGL light }
    SetNoAttenuation := true;

    if (Light.LightNode is TVRMLPositionalLightNode) then
    begin
     Attenuat := TVRMLPositionalLightNode(Light.LightNode).FdAttenuation.Value;
     if not ZeroVector(Attenuat) then
     begin
      SetNoAttenuation := false;
      glLightf(glLightNum, GL_CONSTANT_ATTENUATION, Attenuat[0]);
      glLightf(glLightNum, GL_LINEAR_ATTENUATION, Attenuat[1]);
      glLightf(glLightNum, GL_QUADRATIC_ATTENUATION, Attenuat[2]);
     end;
    end;

    if SetNoAttenuation then
    begin
     { lights with no Attenuation field or with Attenuation = (0, 0, 0)
        get default Attenuation = (1, 0, 0) }
     glLightf(glLightNum, GL_CONSTANT_ATTENUATION, 1);
     glLightf(glLightNum, GL_LINEAR_ATTENUATION, 0);
     glLightf(glLightNum, GL_QUADRATIC_ATTENUATION, 0);
    end;

   finally glPopMatrix end;

   { calculate Color4 = light color * light intensity }
   Color3 := VectorScale(Light.LightNode.FdColor.Value,
     Light.LightNode.FdIntensity.Value);
   Color4 := Vector4Single(Color3, 1);

   { calculate AmbientColor4 = light color * light ambient intensity }
   if Light.LightNode.FdAmbientIntensity.Value < 0 then
     AmbientColor4 := Color4 else
   begin
     AmbientColor3 := VectorScale(Light.LightNode.FdColor.Value,
       Light.LightNode.FdAmbientIntensity.Value);
     AmbientColor4 := Vector4Single(AmbientColor3, 1);
   end;

   glLightv(glLightNum, GL_AMBIENT, AmbientColor4);
   glLightv(glLightNum, GL_DIFFUSE, Color4);
   glLightv(glLightNum, GL_SPECULAR, Color4);
  end;

var
  LightOn: boolean;
begin
  glLightNum += GL_LIGHT0;

  if UseLightOnProperty then
  begin
    LightOn := Light.LightNode.FdOn.Value;
    { Call LightRenderEvent, allowing it to change LightOn value. }
    if Assigned(LightRenderEvent) then
      LightRenderEvent(Light, LightOn);
    if LightOn then
    begin
      glLightFromVRMLLightAssumeOn;
      glEnable(glLightNum);
    end else
      glDisable(glLightNum);
  end else
    glLightFromVRMLLightAssumeOn;
end;

procedure glLightsFromVRML(
  Lights: PArray_ActiveLight; LightsCount: Integer;
  glLightNum1, glLightNum2: Integer;
  LightRenderEvent: TVRMLLightRenderEvent);
var
  I: Integer;
begin
  if LightsCount >= glLightNum2-glLightNum1 + 1  then
  begin
    { use all available OpenGL lights }
    for i := 0 to GLLightNum2 - GLLightNum1 do
      glLightFromVRMLLight(GLLightNum1 + i, Lights^[i], true, LightRenderEvent);
  end else
  begin
    { use some OpenGL lights for VRML lights, disable rest of the lights }
    for i := 0 to LightsCount - 1 do
      glLightFromVRMLLight(GLLightNum1 + i, Lights^[i], true, LightRenderEvent);
    for i := LightsCount to GLLightNum2-GLLightNum1 do
      glDisable(GL_LIGHT0 + GLLightNum1 + i);
  end;
end;

procedure glLightsFromVRML(Lights: TDynActiveLightArray;
  GLLightNum1, GLLightNum2: Integer;
  LightRenderEvent: TVRMLLightRenderEvent);
begin
  glLightsFromVRML(Lights.ItemsArray, Lights.Count, GLLightNum1, GLLightNum2,
    LightRenderEvent);
end;

{ TVRMLGLLightsCachingRenderer ----------------------------------------------- }

constructor TVRMLGLLightsCachingRenderer.Create(
  const AGLLightNum1, AGLLightNum2: Integer;
  const ALightRenderEvent: TVRMLLightRenderEvent);
begin
  inherited Create;
  FGLLightNum1 := AGLLightNum1;
  FGLLightNum2 := AGLLightNum2;
  FLightRenderEvent := ALightRenderEvent;

  LightsKnown := false;
  { avoid range error when GLLightNum2 < GLLightNum1 }
  if GLLightNum2 >= GLLightNum1 then
    SetLength(LightsDone, GLLightNum2 - GLLightNum1 + 1);
end;

procedure TVRMLGLLightsCachingRenderer.Render(Lights: TDynActiveLightArray;
  out LightsEnabled: Cardinal);
begin
  if Lights <> nil then
    Render(Lights.ItemsArray, Lights.Count, LightsEnabled) else
    Render(nil, 0, LightsEnabled);
end;

procedure TVRMLGLLightsCachingRenderer.Render(Lights: PArray_ActiveLight;
  LightsCount: Integer; out LightsEnabled: Cardinal);

  function NeedRenderLight(Index: Integer; Light: PActiveLight): boolean;
  begin
    Result := not (
      LightsKnown and
      ( { Light Index is currently disabled, and we want it disabled: Ok. }
        ( (LightsDone[Index] = nil) and
          (Light = nil) )
        or
        { Light Index is currently enabled, and we want it enabled,
          with the same LightNode and Transform: Ok.
          (Other TActiveLight record properties are calculated from
          LightNode and Transform, so no need to compare them). }
        ( (LightsDone[Index] <> nil) and
          (Light <> nil) and
          (LightsDone[Index]^.LightNode = Light^.LightNode) and
          (MatricesPerfectlyEqual(
            LightsDone[Index]^.Transform, Light^.Transform)) )
      ));
    if Result then
      { Update LightsDone[Index], if change required. }
      LightsDone[Index] := Light;
    Inc(Statistics[Result]);
  end;

var
  I: Integer;
begin
  if LightsCount >= GLLightNum2 - GLLightNum1 + 1  then
  begin
    { use all available OpenGL lights }
    for i := 0 to GLLightNum2 - GLLightNum1 do
      if NeedRenderLight(I, @(Lights^[i])) then
        glLightFromVRMLLight(GLLightNum1 + i, Lights^[i], true, LightRenderEvent);
    LightsEnabled := GLLightNum2 + 1;
  end else
  begin
    { use some OpenGL lights for VRML lights, disable rest of the lights }
    for i := 0 to LightsCount - 1 do
      if NeedRenderLight(I, @(Lights^[i])) then
        glLightFromVRMLLight(GLLightNum1 + i, Lights^[i], true, LightRenderEvent);
    LightsEnabled := GLLightNum1 + LightsCount;
    for i := LightsCount to GLLightNum2-GLLightNum1 do
      if NeedRenderLight(I, nil) then
        glDisable(GL_LIGHT0 + GLLightNum1 + i);
  end;

  LightsKnown := true;
end;

{ TVRMLGLLightSet ------------------------------------------------------------ }

constructor TVRMLGLLightSet.Create(ARootNode: TVRMLNode; AOwnsRootNode: boolean;
  AGLLightNum1, AGLLightNum2: Integer);
begin
  inherited Create(ARootNode, AOwnsRootNode);
  FGLLightNum1 := AGLLightNum1;
  FGLLightNum2 := AGLLightNum2;
end;

function TVRMLGLLightSet.RealGLLightNum2: Integer;
begin
  Result := GLLightNum2;
  if Result = -1 then
    Result += GLMaxLights;
end;

procedure TVRMLGLLightSet.RenderLights;
begin
  glLightsFromVRML(Lights, glLightNum1, RealGLLightNum2, nil);
end;

procedure TVRMLGLLightSet.TurnLightsOff;
var
  I: Integer;
begin
  for I := GLLightNum1 to RealGLLightNum2 do
    glDisable(GL_LIGHT0 + I);
end;

procedure TVRMLGLLightSet.TurnLightsOffForShadows;
var
  MyLightNum, GLLightNum: Integer;
  L: PActiveLight;
begin
  L := Lights.Pointers[0];
  for MyLightNum := 0 to Lights.Count - 1 do
  begin
    GLLightNum := MyLightNum + GLLightNum1;

    if L^.LightNode.FdKambiShadows.Value then
    begin
      if GLLightNum <= RealGLLightNum2 then
        glDisable(GL_LIGHT0 + GLLightNum);
    end;

    Inc(L);
  end;
end;

end.

