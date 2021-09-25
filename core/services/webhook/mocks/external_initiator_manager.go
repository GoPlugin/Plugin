// Code generated by mockery v2.8.0. DO NOT EDIT.

package mocks

import (
	job "github.com/GoPlugin/Plugin/core/services/job"
	mock "github.com/stretchr/testify/mock"

	models "github.com/GoPlugin/Plugin/core/store/models"

	uuid "github.com/satori/go.uuid"
)

// ExternalInitiatorManager is an autogenerated mock type for the ExternalInitiatorManager type
type ExternalInitiatorManager struct {
	mock.Mock
}

// DeleteJob provides a mock function with given fields: jobID
func (_m *ExternalInitiatorManager) DeleteJob(jobID models.JobID) error {
	ret := _m.Called(jobID)

	var r0 error
	if rf, ok := ret.Get(0).(func(models.JobID) error); ok {
		r0 = rf(jobID)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// DeleteJobV2 provides a mock function with given fields: _a0
func (_m *ExternalInitiatorManager) DeleteJobV2(_a0 job.Job) error {
	ret := _m.Called(_a0)

	var r0 error
	if rf, ok := ret.Get(0).(func(job.Job) error); ok {
		r0 = rf(_a0)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// FindExternalInitiatorByName provides a mock function with given fields: name
func (_m *ExternalInitiatorManager) FindExternalInitiatorByName(name string) (models.ExternalInitiator, error) {
	ret := _m.Called(name)

	var r0 models.ExternalInitiator
	if rf, ok := ret.Get(0).(func(string) models.ExternalInitiator); ok {
		r0 = rf(name)
	} else {
		r0 = ret.Get(0).(models.ExternalInitiator)
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(string) error); ok {
		r1 = rf(name)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Notify provides a mock function with given fields: _a0
func (_m *ExternalInitiatorManager) Notify(_a0 models.JobSpec) error {
	ret := _m.Called(_a0)

	var r0 error
	if rf, ok := ret.Get(0).(func(models.JobSpec) error); ok {
		r0 = rf(_a0)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// NotifyV2 provides a mock function with given fields: jobID, initrName, initrSpec
func (_m *ExternalInitiatorManager) NotifyV2(jobID uuid.UUID, initrName string, initrSpec *models.JSON) error {
	ret := _m.Called(jobID, initrName, initrSpec)

	var r0 error
	if rf, ok := ret.Get(0).(func(uuid.UUID, string, *models.JSON) error); ok {
		r0 = rf(jobID, initrName, initrSpec)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}
