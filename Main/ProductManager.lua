local ProductManager = {}

-- Table to store product data
local products = {
    [101] = {
        Name = "Starter Pack",
        Price = 100,
        Enabled = true,
        EnforceBlacklist = true, -- General blacklist enforcement toggle
        Blacklist = {
            [12345678] = {Reason = "Attempted chargeback", Disabled = false}, -- Blacklist enabled for this user
            [87654321] = {Reason = "Abusive behavior", Disabled = true} -- Blacklist disabled for this user
        },
        Description = "A pack to get started quickly!",
        Category = "Bundle"
    },
    [102] = {
        Name = "VIP Access",
        Price = 500,
        Enabled = false,
        EnforceBlacklist = false,
        Blacklist = {},
        Description = "Exclusive access to VIP areas.",
        Category = "Membership"
    }
}

-- Function to get product info
function ProductManager:GetProduct(productId)
    return products[productId] or nil
end

-- Function to check if a user is blacklisted
function ProductManager:IsBlacklisted(productId, userId)
    local product = self:GetProduct(productId)
    if not product or not product.Blacklist then return false end
    local blacklistEntry = product.Blacklist[userId]
    return blacklistEntry and not blacklistEntry.Disabled or false
end

-- Function to get the blacklist reason for a user
function ProductManager:GetBlacklistReason(productId, userId)
    local product = self:GetProduct(productId)
    if not product or not product.Blacklist then return nil end
    local blacklistEntry = product.Blacklist[userId]
    return blacklistEntry and blacklistEntry.Reason or nil
end

-- Function to enforce blacklist and get status/reason
function ProductManager:CanAccessProduct(productId, userId)
    local product = self:GetProduct(productId)
    if not product then return false, "Product does not exist" end
    if not product.Enabled then return false, "Product is disabled" end
    if product.EnforceBlacklist and self:IsBlacklisted(productId, userId) then
        local reason = self:GetBlacklistReason(productId, userId)
        return false, reason or "No reason provided"
    end
    return true, "Access granted"
end

-- Function to add a user to a product's blacklist
function ProductManager:AddToBlacklist(productId, userId, reason)
    local product = self:GetProduct(productId)
    if product then
        product.Blacklist[userId] = {Reason = reason or "No reason provided", Disabled = false}
    end
end

-- Function to remove a user from a product's blacklist
function ProductManager:RemoveFromBlacklist(productId, userId)
    local product = self:GetProduct(productId)
    if product and product.Blacklist then
        product.Blacklist[userId] = nil
    end
end

-- Function to enable or disable blacklist for a specific user
function ProductManager:SetBlacklistStatus(productId, userId, status)
    local product = self:GetProduct(productId)
    if product and product.Blacklist and product.Blacklist[userId] then
        product.Blacklist[userId].Disabled = not status
    end
end

return ProductManager
