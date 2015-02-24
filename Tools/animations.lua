local _, ns = ...

--[=============================================[

	For fading frame, almost like UIFrameFadeIn/Out

	But doesnt call Hide() or Show() so can be used on secure frames

--]=============================================]

local FadeManager = CreateFrame("FRAME");
local FADINGFRAMES = {}

local function FadeManager_OnUpdate(self, elapsed)
	local index = 1;
	local frame, fadeInfo;
	while FADINGFRAMES[index] do
		frame = FADINGFRAMES[index];
		fadeInfo = FADINGFRAMES[index].fadeInfo;
		-- Reset the timer if there isn't one, this is just an internal counter
		if ( not fadeInfo.fadeTimer ) then
			fadeInfo.fadeTimer = 0;
		end
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed;
 
		-- If there is a fadeHoldTime then wait until its passed to continue on
		if ( fadeInfo.waitTime and fadeInfo.waitTime > 0  ) then
			frame:SetAlpha(fadeInfo.startAlpha)
			fadeInfo.waitTime = fadeInfo.waitTime - elapsed;
			
		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade 
		elseif ( fadeInfo.fadeTimer < fadeInfo.timeToFade ) then
			if ( fadeInfo.mode == "IN" ) then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha);
			elseif ( fadeInfo.mode == "OUT" ) then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha);
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha);
			-- Complete the fade and call the finished function if there is one
			tDeleteItem(FADINGFRAMES, frame);
			if ( fadeInfo.finishedFunc ) then
				fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4);
				fadeInfo.finishedFunc = nil;
			end
		end
		index = index + 1;
	end
	 
	if ( #FADINGFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

-- Generic fade function
local function FadeFrame(frame, fadeInfo)
	if (not frame) then
		return;
	end
	if ( not fadeInfo.mode ) then
		fadeInfo.mode = "IN";
	end
	local alpha;
	if ( fadeInfo.mode == "IN" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0;
		end
		alpha = 0;
	elseif ( fadeInfo.mode == "OUT" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0;
		end
		alpha = 1.0;
	end

	-- Holding the frame travels back in time
	if ( fadeInfo.waitTime and fadeInfo.waitTime > 0 ) then
		fadeInfo.fadeTimer = - fadeInfo.waitTime
	end

	frame:SetAlpha(fadeInfo.startAlpha);
	frame.fadeInfo = fadeInfo;
 
	local index = 1;
	while FADINGFRAMES[index] do
		-- If frame is already set to fade, stop!
		if ( FADINGFRAMES[index] == frame ) then
			-- its currently moving, queue it up after the animation is finished
			FADINGFRAMES[index].fadeInfo.endFunc = FadeFrame
			FADINGFRAMES[index].fadeInfo.arg1 = frame
			FADINGFRAMES[index].fadeInfo.arg2 = fadeInfo
			return;
		end
		index = index + 1;
	end
	tinsert(FADINGFRAMES, frame);
	FadeManager:SetScript("OnUpdate", FadeManager_OnUpdate);
end
 
-- Convenience function to do a simple fade in
function ns.UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha, waitTime)
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	fadeInfo.waitTime = waitTime
	FadeFrame(frame, fadeInfo);
end
 
-- Convenience function to do a simple fade out
function ns.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha, waitTime)
	local fadeInfo = {};
	fadeInfo.mode = "OUT";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	fadeInfo.waitTime = waitTime
	FadeFrame(frame, fadeInfo);
end

--[=============================================[

	For Sliding frames
	horOrVert: 'X' or 'Y'
	AnimationSlideStart(frame, timeToSlide, horOrVert, distToSlide)
	AnimationSlideReturn(frame, delay)

--]=============================================]

local SlideManager = CreateFrame("Frame")
local SLIDEFRAMES = {}
local RETURNFRAMES = {}

local START_POSITION = 0
local ANIMATING_OUT = 1
local END_POSITION = 2
local ANIMATING_IN = 3

local function SlideManager_OnUpdate(self, elapsed)
	local i = 1;
	local frame, slideInfo;
	while SLIDEFRAMES[i] do
		frame = SLIDEFRAMES[i]
		slideInfo = SLIDEFRAMES[i].slideInfo
		slideInfo.slideTimer = slideInfo.slideTimer + elapsed;
		-- delay, lets wait
		if slideInfo.delay then
			if slideInfo.delay > slideInfo.slideTimer then
				slideInfo.delay = slideInfo.delay - elapsed
			else
				-- reset the timer
				slideInfo.delay = nil
				slideInfo.slideTimer = 0
				slideInfo.stage = ANIMATING_IN
			end
		else
			local distance 
			if slideInfo.stage == ANIMATING_IN then
				distance = -slideInfo.distance
			else
				distance = slideInfo.distance
			end
			local p, a, rp, x, y = unpack(slideInfo.origPos)

			-- Sliding isnt done yet
			if slideInfo.slideTimer < slideInfo.timeToSlide then
				local yPos, xPos
				if slideInfo.dir == 'Y' then
					if slideInfo.stage == ANIMATING_IN then
						yPos = (slideInfo.slideTimer/slideInfo.timeToSlide)^2 * (distance) + (y - distance);
					else
						yPos = sqrt(slideInfo.slideTimer/slideInfo.timeToSlide) * (distance) + y;
					end
					frame:SetPoint(p, a, rp, x, yPos)
				elseif slideInfo.dir == 'X' then
					if slideInfo.stage == ANIMATING_IN then
						xPos = (slideInfo.slideTimer/slideInfo.timeToSlide)^2 * (distance) + (x - distance);
					else
						xPos = sqrt(slideInfo.slideTimer/slideInfo.timeToSlide) * (distance) + x;
					end
					frame:SetPoint(p, a, rp, xPos, y)
				end
			-- Were finished
			else
				if slideInfo.stage == ANIMATING_IN then -- Put it back in original position
					frame:SetPoint(p, a, rp, x, y);
					slideInfo.stage = START_POSITION
				elseif slideInfo.dir == 'Y' then
					slideInfo.stage = END_POSITION
					frame:SetPoint(p, a, rp, x, (y + distance));
				elseif slideInfo.dir == 'X' then
					slideInfo.stage = END_POSITION
					frame:SetPoint(p, a, rp, (x + distance), y);
				end
				-- Run the finish function if there is one
				if slideInfo.endFunc then
					slideInfo.endFunc(slideInfo.arg1, slideInfo.arg2)
					slideInfo.endFunc, slideInfo.arg1, slideInfo.arg2 = nil, nil, nil;
				end
				slideInfo.slideTimer = 0;
				-- Finished, remove it from the cache
				tDeleteItem(SLIDEFRAMES, frame);
			end
		end
		i = i + 1
	end

	if ( #SLIDEFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

local function AnimationSlideStart(frame, func, arg1, arg2)

	local index = 1;
	while SLIDEFRAMES[index] do
		-- If frame is already set to sliding 
		if ( SLIDEFRAMES[index] == frame ) then
			if frame.slideInfo.stage == END_POSITION then
				-- If its waiting to go back, cancel it
				tDeleteItem(SLIDEFRAMES, frame)
				frame.slideInfo.stage = END_POSITION
				frame.slideInfo.slideTimer = 0
				tinsert(RETURNFRAMES, frame)
			end
			return;
		end
		index = index + 1;
	end

	index = 1;
	while RETURNFRAMES[index] do
		-- If frame hasnt returned yet, we cant move it
		if ( RETURNFRAMES[index] == frame ) then
			return;
		end
		index = index + 1;
	end

	frame.slideInfo.endFunc = func;
	frame.slideInfo.arg1 = arg1;
	frame.slideInfo.arg2 = arg2;
	frame.slideInfo.stage = ANIMATING_OUT;

	tinsert(RETURNFRAMES, frame);
	tinsert(SLIDEFRAMES, frame);
	SlideManager:SetScript("OnUpdate", SlideManager_OnUpdate);
end

local function AnimationSlideReturn(frame, delay)
	if (not frame) then
		return;
	end
	local index = 1;
	while SLIDEFRAMES[index] do
		if ( SLIDEFRAMES[index] == frame ) then
			-- its currently moving, queue it up after the animation is finished
			SLIDEFRAMES[index].slideInfo.endFunc = AnimationSlideReturn
			SLIDEFRAMES[index].slideInfo.arg1 = frame
			SLIDEFRAMES[index].slideInfo.arg2 = delay
			return;
		end
		index = index + 1;
	end

	if delay and delay <= 0 then delay = nil; end

	local index = 1;
	while RETURNFRAMES[index] do
		-- Found the frame!
		if ( RETURNFRAMES[index] == frame ) and frame.slideInfo then
			frame.slideInfo.stage = delay and END_POSITION or ANIMATING_IN
			frame.slideInfo.delay = delay
			tinsert(SLIDEFRAMES, frame)
			tDeleteItem(RETURNFRAMES, frame)
			SlideManager:SetScript("OnUpdate", SlideManager_OnUpdate)
			return;
		end
		index = index + 1;
	end
end

function ns.SetupFrameForSliding(frame, timeToSlide, horOrVert, distToSlide)
	if (not frame) then
		return;
	end

	if (horOrVert ~= 'Y' and horOrVert ~= 'X') then
		horOrVert = "Y";
	end

	local slideInfo = frame.slideInfo and wipe(frame.slideInfo) or { };
	slideInfo.origPos = {frame:GetPoint()}
	slideInfo.dir = horOrVert
	slideInfo.timeToSlide = timeToSlide
	slideInfo.distance = distToSlide
	slideInfo.stage = START_POSITION
	slideInfo.slideTimer = 0
	frame.slideInfo = slideInfo

	frame.AnimationSlideReturn = AnimationSlideReturn
	frame.AnimationSlideStart = AnimationSlideStart
end