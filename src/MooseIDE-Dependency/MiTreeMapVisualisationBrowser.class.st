"
Shows the containment (direct relations for now) between entities.
Dynamic presentation: clicking on an entity shows the entities it contains.

- Follow: Receives MooseObjects.
- Highlight: Entities if present.
- Propagate: <TODO>
"
Class {
	#name : #MiTreeMapVisualisationBrowser,
	#superclass : #MiAbstractDependencyBrowser,
	#instVars : [
		'diagram'
	],
	#category : #'MooseIDE-Dependency-TreeMap'
}

{ #category : #specs }
MiTreeMapVisualisationBrowser class >> defaultSpec [
	^ super defaultSpec
		add: #diagram;
		yourself
]

{ #category : #specs }
MiTreeMapVisualisationBrowser class >> menuCommandOn: aBuilder [
	<worldMenu>
	<miBrowsers>
	(aBuilder item: #TreeMapVisualisationBrowser)
		parent: self toolbarDependencyName;
		label: self title;
		icon: (self iconNamed: #mooseTreeMap);
		help: self helpMessage;
		order: 3.0;
		action: [ self open ]
]

{ #category : #'instance creation' }
MiTreeMapVisualisationBrowser class >> newModel [

	^ MiTreeMapVisualisationModel new
]

{ #category : #specs }
MiTreeMapVisualisationBrowser class >> open [
	<script>
	^ super open
]

{ #category : #accessing }
MiTreeMapVisualisationBrowser class >> title [
	^ 'Tree Map Visualization'
]

{ #category : #testing }
MiTreeMapVisualisationBrowser >> canHighlight [

	^ true
]

{ #category : #testing }
MiTreeMapVisualisationBrowser >> canReceiveEntity: anObject [

	^ anObject isMooseObject and: [ anObject rootsForTreeMap isNotEmpty ]
]

{ #category : #actions }
MiTreeMapVisualisationBrowser >> followEntity: anEntity [

	model entities: anEntity rootsForTreeMap.
	diagram run
]

{ #category : #actions }
MiTreeMapVisualisationBrowser >> highlightEntity: anEntity [

	diagram highlightEntities: anEntity rootsForTreeMap
]

{ #category : #initialization }
MiTreeMapVisualisationBrowser >> initializePresenters [

	diagram := self instantiate: MiTreeMap
]

{ #category : #accessing }
MiTreeMapVisualisationBrowser >> miSelectedItem [

	^ model entities mooseInterestingEntity
]