package com.skooairs.resources
{
	      	 
public class SoundsContainer
{
	//   ======================================================================//
	
	[Embed(source="resources/embed/sounds/bip.mp3")] 
	[Bindable] public static var BIP:Class;

	[Embed(source="resources/embed/sounds/yeah.mp3")]
	[Bindable] public static var YEAH:Class;

	[Embed(source="resources/embed/sounds/ok.mp3")]
	[Bindable] public static var OK:Class;

	[Embed(source="resources/embed/sounds/explosion.mp3")]
	[Bindable] public static var EXPLOSION:Class;

	[Embed(source="resources/embed/sounds/load.mp3")]
	[Bindable] public static var LOAD:Class;

	[Embed(source="resources/embed/sounds/clic.mp3")]
	[Bindable] public static var CLIC:Class;

	//   ======================================================================//


}
}