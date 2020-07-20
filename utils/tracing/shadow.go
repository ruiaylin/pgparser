// Copyright 2017 The Cockroach Authors.
//
// Use of this software is governed by the Business Source License
// included in the file licenses/BSL.txt.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the Apache License, Version 2.0, included in the file
// licenses/APL.txt.
//
// A "shadow" tracer can be any opentracing.Tracer implementation that is used
// in addition to the normal functionality of our tracer. It works by attaching
// a shadow span to every span, and attaching a shadow context to every span
// context. When injecting a span context, we encapsulate the shadow context
// inside ours.

package tracing

import (
	"context"
	"time"

	"github.com/ruiaylin/pgparser/utils"
	lightstep "github.com/lightstep/lightstep-tracer-go"
	opentracing "github.com/opentracing/opentracing-go"
	
)

type shadowTracerManager interface {
	Name() string
	Close(tr opentracing.Tracer)
}

type lightStepManager struct{}

func (lightStepManager) Name() string {
	return "lightstep"
}

func (lightStepManager) Close(tr opentracing.Tracer) {
	lightstep.Close(context.TODO(), tr)
}

type zipkinManager struct {
	
}

func (*zipkinManager) Name() string {
	return "zipkin"
}

func (m *zipkinManager) Close(tr opentracing.Tracer) {
	
}

type shadowTracer struct {
	opentracing.Tracer
	manager shadowTracerManager
}

func (st *shadowTracer) Typ() string {
	return st.manager.Name()
}

func (st *shadowTracer) Close() {
	st.manager.Close(st)
}

// linkShadowSpan creates and links a Shadow span to the passed-in span (i.e.
// fills in s.shadowTr and s.shadowSpan). This should only be called when
// shadow tracing is enabled.
//
// The Shadow span will have a parent if parentShadowCtx is not nil.
// parentType is ignored if parentShadowCtx is nil.
//
// The tags (including logTags) from s are copied to the Shadow span.
func linkShadowSpan(
	s *span,
	shadowTr *shadowTracer,
	parentShadowCtx opentracing.SpanContext,
	parentType opentracing.SpanReferenceType,
) {
	// Create the shadow lightstep span.
	var opts []opentracing.StartSpanOption
	// Replicate the options, using the lightstep context in the reference.
	opts = append(opts, opentracing.StartTime(s.startTime))
	if s.logTags != nil {
		opts = append(opts, LogTags(s.logTags))
	}
	if s.mu.tags != nil {
		opts = append(opts, s.mu.tags)
	}
	if parentShadowCtx != nil {
		opts = append(opts, opentracing.SpanReference{
			Type:              parentType,
			ReferencedContext: parentShadowCtx,
		})
	}
	s.shadowTr = shadowTr
	s.shadowSpan = shadowTr.StartSpan(s.operation, opts...)
}

func createLightStepTracer(token string) (shadowTracerManager, opentracing.Tracer) {
	return lightStepManager{}, lightstep.NewTracer(lightstep.Options{
		AccessToken:      token,
		MaxLogsPerSpan:   maxLogsPerSpan,
		MaxBufferedSpans: 10000,
		UseGRPC:          true,
	})
}

var zipkinLogEveryN = utils.Every(5 * time.Second)

func createZipkinTracer(collectorAddr string) (shadowTracerManager, opentracing.Tracer) {
	// Create our HTTP collector.


	// Create our tracer.
	return &zipkinManager{}, nil
}
