Class {
	#name : #MiBooleanQueryPresenterTest,
	#superclass : #MiPropertyQueryPresenterTest,
	#category : #'MooseIDE-QueriesBrowser-Tests-Queries Configuration'
}

{ #category : #tests }
MiBooleanQueryPresenterTest >> assertSubpresentersAreConfigured [

	self assert: presenter propertyDropList selectedItem equals: self createNewQuery property
]

{ #category : #running }
MiBooleanQueryPresenterTest >> classToTest [
	^ MiBooleanQueryPresenter
]

{ #category : #tests }
MiBooleanQueryPresenterTest >> createNewQuery [

	| rootQuery |
	rootQuery := FQRootQuery new
		result: helper classesAndMethods;
		yourself.
	^ (FQBooleanQuery defaultForParent: rootQuery)
			property: #isStub;
			yourself
]

{ #category : #running }
MiBooleanQueryPresenterTest >> queryClass [
	^ FQBooleanQuery
]