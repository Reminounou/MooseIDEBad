"
Shows UML of the received entities.

- Follow: Receives a TypeGroup or entities using TType.
- Highlight: Entities if present
- Propagate: The selected entity if there is one
"
Class {
	#name : #MiUMLBrowser,
	#superclass : #MiAbstractFamixBrowser,
	#instVars : [
		'diagram'
	],
	#category : #'MooseIDE-Famix-UML'
}

{ #category : #specs }
MiUMLBrowser class >> defaultSpec [
	^ super defaultSpec
		add: #diagram;
		yourself
]

{ #category : #specs }
MiUMLBrowser class >> menuCommandOn: aBuilder [
	<worldMenu>
	<miBrowsers>
	(aBuilder item: #UMLVisualisationBrowser)
		parent: (self toolbarFamixName);
		label: (self title);
		icon: (self iconNamed: #mooseUml);
		order: 4;
		help: (self helpMessage);
		action: [ self open ]
]

{ #category : #'instance creation' }
MiUMLBrowser class >> newModel [

	^ MiUMLModel new
]

{ #category : #specs }
MiUMLBrowser class >> open [
	<script>
	^ super open
]

{ #category : #TOREMOVE }
MiUMLBrowser class >> title [
	^ 'UML'
]

{ #category : #testing }
MiUMLBrowser >> canHighlight [

	^ true
]

{ #category : #testing }
MiUMLBrowser >> canReceiveEntity: anObject [

	^ anObject isMooseObject and: [ 
		  anObject asMooseSpecializedGroup isKindOf: FamixTypeGroup ]
]

{ #category : #actions }
MiUMLBrowser >> followEntity: anEntity [

	model
		entities: anEntity asMooseSpecializedGroup;
		unselectAll.
	diagram run
]

{ #category : #actions }
MiUMLBrowser >> highlightEntity: anEntity [

	diagram highlightEntities: anEntity asCollection
]

{ #category : #initialization }
MiUMLBrowser >> initializePresenters [

	diagram := self instantiate: MiUML
]

{ #category : #accessing }
MiUMLBrowser >> miSelectedItem [

	^ (model selected ifNil: [ model entities ]) mooseInterestingEntity
]