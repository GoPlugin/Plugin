// Code generated by mockery v2.8.0. DO NOT EDIT.

package mocks

import (
	context "context"

	models "github.com/GoPlugin/Plugin/core/store/models"
	mock "github.com/stretchr/testify/mock"
)

// HeadTrackable is an autogenerated mock type for the HeadTrackable type
type HeadTrackable struct {
	mock.Mock
}

// Connect provides a mock function with given fields: head
func (_m *HeadTrackable) Connect(head *models.Head) error {
	ret := _m.Called(head)

	var r0 error
	if rf, ok := ret.Get(0).(func(*models.Head) error); ok {
		r0 = rf(head)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// Disconnect provides a mock function with given fields:
func (_m *HeadTrackable) Disconnect() {
	_m.Called()
}

// OnNewLongestChain provides a mock function with given fields: ctx, head
func (_m *HeadTrackable) OnNewLongestChain(ctx context.Context, head models.Head) {
	_m.Called(ctx, head)
}
